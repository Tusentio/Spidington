extends Node2D

func _input(event):
	if Input.is_action_just_pressed("pause_menu"):
		SceneChanger.change_scene(SceneChanger.MENU);
