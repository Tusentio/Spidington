extends Button


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
	
func _ready():
	if PlayerData.read().saved:
		text = "Continue"
