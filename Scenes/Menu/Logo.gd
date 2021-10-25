extends AnimatedSprite

func _ready():
	playing = true;


func _on_Logo_animation_finished():
	play("idle")
