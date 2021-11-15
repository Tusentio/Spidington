tool
extends Node2D

export (float) var radius := 150.0
export (float) var margin := 3.0

var in_range := false


func _process(_delta):
	if Engine.is_editor_hint():
		in_range = get_local_mouse_position().length() < radius
		update()


func _draw():
	if Engine.is_editor_hint() and in_range:
		var global_mouse := get_global_mouse_position()
		var local_mouse := to_local(global_mouse)
		var normal := local_mouse.normalized()
		var space_state := get_world_2d().direct_space_state
		var obstruction := space_state.intersect_ray(global_position + normal * margin,
			get_global_mouse_position() - normal * margin, [], 0b10)
		if not obstruction:
			draw_line(Vector2.ZERO + normal * margin,
				local_mouse - normal * margin, Color.white, 1.0)
