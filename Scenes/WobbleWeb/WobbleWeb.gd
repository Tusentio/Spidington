extends Area2D

func _on_WobbleWeb_body_entered(body):
	$Animator.play("Wobble");
