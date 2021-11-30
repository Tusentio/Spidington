extends Camera2D

func _ready():
	$Tween.interpolate_property(self, "zoom",
		Vector2(0.2, 0.2), Vector2(0.4, 0.4), 1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT);
	$Tween.start();
