extends Control

func _on_Timer_timeout():
	SceneChanger.change_scene(SceneChanger.GAME);
