extends CanvasLayer

const MENU = "res://Scenes/Menu/Menu.tscn";
const GAME = "res://Scenes/Game/Game.tscn";
const CREDITS = "res://Scenes/Credits/Credits.tscn";

var is_changing = false;

func change_scene(scene):
	if is_changing: return;
	
	is_changing = true;
	get_tree().get_root().set_disable_input(true);
	
	# Fade to black
	$AnimationPlayer.play("Fade");
	yield($AnimationPlayer, "animation_finished");
	
	# Change scene
	get_tree().change_scene(scene);
	
	# Fade from black
	$AnimationPlayer.play_backwards("Fade");
	
	is_changing = false;
	get_tree().get_root().set_disable_input(false);
