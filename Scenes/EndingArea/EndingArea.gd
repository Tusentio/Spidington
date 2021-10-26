extends Area2D

var reset := false


func _on_EndingArea_body_entered(body):
	# Reset save
	PlayerData.new().save()
	
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/Credits/Credits.tscn")
