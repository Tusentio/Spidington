extends Button

func _on_RestartButton_pressed():
	PlayerData.new().save()
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
