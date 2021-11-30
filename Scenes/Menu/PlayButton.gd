extends Button


func _on_PlayButton_pressed():
	SceneChanger.change_scene(SceneChanger.INTRO);
	
func _ready():
	if PlayerData.read().saved:
		text = "Continue"
