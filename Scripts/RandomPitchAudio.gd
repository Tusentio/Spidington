extends AudioStreamPlayer2D

export (float) var pitch_scale_range := 0.1

onready var pitch_scale_center := pitch_scale

func play(from_position = 0.0):
	pitch_scale = pitch_scale_center + rand_range(-0.5, 0.5) * pitch_scale_range
	.play(from_position)
