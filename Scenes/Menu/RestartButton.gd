extends Button

func _on_RestartButton_pressed():
	# Reset save
	PlayerData.reset()
	get_tree().reload_current_scene()
	
func _ready():
	if not PlayerData.read().saved:
		visible = false
