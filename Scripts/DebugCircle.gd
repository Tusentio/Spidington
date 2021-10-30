tool
extends Node2D

export (float) var radius := 150.0


func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, radius, Color.white)
