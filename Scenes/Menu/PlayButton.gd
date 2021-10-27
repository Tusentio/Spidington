extends Button


func _on_PlayButton_pressed():
	SceneChanger.change_scene(SceneChanger.GAME);
	
func _ready():
	if PlayerData.read().saved:
		text = "Continue"
