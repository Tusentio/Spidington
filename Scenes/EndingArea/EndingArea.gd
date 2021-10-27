extends Area2D

var reset := false


func _on_EndingArea_body_entered(body):
	# Reset save
	PlayerData.new().save()
	
	SceneChanger.change_scene(SceneChanger.CREDITS);
