extends Control

export (float) var text_speed := 0.0
export (float) var text_acceleration := 2.0

func _input(event):
	if Input.is_action_just_pressed("pause_menu"):
		get_tree().change_scene("res://Scenes/Menu/Menu.tscn")

func _ready():
	$Content/Label.percent_visible = 0
	
	# Display final time
	var player_data: PlayerData = PlayerData.read()
	if player_data.saved:
		$TimerLabel.text = (String(player_data.time_major) + "." +
			String(int(player_data.time_minor * 1000)).pad_zeros(3))
		var data = JSON.print(player_data)
		$HTTPRequest.request("www.google.se", ["Content-Type: application/json"], true,
			HTTPClient.METHOD_POST, data)
			
	# Reset save
	PlayerData.new().save()

func _process(delta):
	if $Content/Label.percent_visible < 1:
		$Content/Label.percent_visible += text_speed * delta
		text_speed += text_acceleration * delta
