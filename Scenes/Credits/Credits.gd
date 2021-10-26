extends Control

func _input(event):
	if Input.is_action_just_pressed("pause_menu"):
		get_tree().change_scene("res://Scenes/Menu/Menu.tscn")
