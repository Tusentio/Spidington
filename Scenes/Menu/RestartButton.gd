extends Button

func _on_RestartButton_pressed():
	PlayerData.new().save()
	SceneChanger.change_scene(SceneChanger.GAME);
	
func _ready():
	if not PlayerData.read().saved:
		visible = false
