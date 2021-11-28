extends Node

export (String) var analytics_url: String
export (PoolStringArray) var custom_headers: PoolStringArray
export (bool) var use_ssl := true
export (bool) var exit_on_fail := false
export (float) var flush_interval := 60.0

var last_flush := OS.get_system_time_msecs()
var event_queue := []


func _ready():
	$FlushTimer.wait_time = flush_interval
	if flush_interval:
		$FlushTimer.start()


func send_event(name: String, data = 0):
	event_queue.append({
		n = name,
		m = data,
		t = OS.get_system_time_msecs(),
	})


func flush():
	if event_queue.empty():
		return
	
	var current_time := OS.get_system_time_msecs()
	var queue_duration := current_time - last_flush
	last_flush = current_time
	
	var data := to_json({
		sid = get_uid(),
		iat = current_time,
		dur = queue_duration,
		evq = event_queue
	})
	
	var headers: PoolStringArray = []
	headers.append_array(custom_headers)
	headers.append("content-type: application/json")
	
	$HTTPRequest.request(analytics_url, headers, use_ssl, HTTPClient.METHOD_POST, data)
	event_queue.clear()


func flush_await():
	flush()
	yield($HTTPRequest, "request_completed")


static func get_uid():
	return OS.get_unique_id().sha256_text()


func _on_HTTPRequest_request_completed(result, response_code, headers, body: PoolByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code >= 400:
		if OS.is_debug_build():
			print("Analytics Error " + to_json({
				result = result,
				response_code = response_code,
				headers = headers,
				body = body.get_string_from_utf8(),
			}))
		elif exit_on_fail:
			get_tree().quit()


func _on_FlushTimer_timeout():
	flush()
	
	$FlushTimer.stop()
	$FlushTimer.wait_time = flush_interval
	if flush_interval:
		$FlushTimer.start()
