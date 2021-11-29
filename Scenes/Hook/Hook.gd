extends StaticBody2D
class_name Hook

func anchored():
	$Indicator.visible = false;
	$HitSound.play()
	$Hook.get_node("Animator").play("Anchored");
	pass;

func unanchored():
	$Indicator.visible = true;
	$Hook.get_node("Animator").stop();
	$Hook.get_node("Animator").seek(0, true);
	pass;
