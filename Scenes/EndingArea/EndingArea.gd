extends Area2D

func _on_EndingArea_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/Credits/Credits.tscn");
