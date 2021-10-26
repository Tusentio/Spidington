extends Control


func _ready():
	OS.window_fullscreen = true
	$ColorRect/ButtonContainer/PlayButton.grab_focus()

