extends Area2D

var collected = false;

func _on_Area2D_body_entered(body):
	if not collected:
		visible = false;
		$Pickup.play();
		yield($Pickup, "finished")
		queue_free();
