extends Button


func _on_PlayButton_pressed():
	if PlayerData.read().saved:
		SceneChanger.change_scene(SceneChanger.GAME);
	else:
		SceneChanger.change_scene(SceneChanger.INTRO);
	
func _ready():
	if PlayerData.read().saved:
		text = "Continue"
