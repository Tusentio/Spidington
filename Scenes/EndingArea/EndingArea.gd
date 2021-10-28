extends Area2D

var reset := false


func _on_EndingArea_body_entered(body):	
	SceneChanger.change_scene(SceneChanger.CREDITS);
