extends Node2D

func _ready():
	visible = false;

# Show if player presses W,A,S,D or Space
func _input(event): 
	if Input.is_action_just_pressed("warning_trigger"):
		visible = true;
		$Animator.play("Warning");

# Hide when node exits screen
func _on_VisibilityNotifier2D_screen_exited():
	visible = false;
