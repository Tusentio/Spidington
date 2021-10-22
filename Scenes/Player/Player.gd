extends Node2D

export (float) var string_speed := 500.0

var hung_position := Vector2.ZERO
var _is_ready := false

onready var hook := $Hook
onready var spindel := $Spindel
onready var shoot_origin := $Spindel/ShootOrigin


func _ready():
	_is_ready = true


func _input(event):
	if Input.is_action_just_pressed("shoot_string") and not hung_position:
		var mouse := get_global_mouse_position()
		var space_rid := get_world_2d().space
		var space_state := Physics2DServer.space_get_direct_state(space_rid)
		var hit := space_state.intersect_ray(shoot_origin.global_position, mouse, [], 0b100)
		
		if hit:
			hung_position = hit.position
			hook.global_position = shoot_origin.global_position
			hook.visible = true


func _process(delta):
	if not _is_ready: return
	
	if hung_position and hook.global_position != hung_position:
		var hook_offset: Vector2 = hung_position - hook.global_position
		var frame_move = hook_offset.normalized() * delta * string_speed
		
		if hook_offset.length() > frame_move.length():
			hook.global_position += frame_move
		else:
			hook.global_position = hung_position
