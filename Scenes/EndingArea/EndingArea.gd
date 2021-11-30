extends Area2D

var reset := false


func _on_EndingArea_body_entered(body):
	AnalyticsCollector.send_event("the_end")
	SceneChanger.change_scene(SceneChanger.CREDITS)
