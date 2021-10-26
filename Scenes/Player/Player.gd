extends RigidBody2D

const scn_spurt := preload("res://Scenes/Spurt/Spurt.tscn")

export (float) var spurt_velocity := 10.0
export (float) var move_force_multiplier := 0.015
export (float) var max_move_force := 15
export (float) var linear_drag := 0.1
export (float) var angular_drag := 0.1

onready var shoot_origin := $ShootOrigin
var _is_ready := false
var spurt: Spurt = null

var mouse_update_duration := 0.0
var mouse_velocity := Vector2.ZERO


func _ready():
	_is_ready = true


func _process(delta):
	mouse_update_duration += delta
	
	if is_instance_valid(spurt) and spurt.is_anchored() and spurt.is_hooked():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	linear_velocity *= pow(1 / (1 + linear_drag), delta)
	angular_velocity *= pow(1 / (1 + angular_drag), delta)
	
	if is_instance_valid(spurt) and spurt.is_anchored() and spurt.is_hooked():
		var string_normal := (spurt.global_position - global_position).normalized()
		apply_impulse(shoot_origin.global_position - global_position, string_normal.normalized() * clamp(-mouse_velocity.dot(string_normal) * move_force_multiplier, 0, max_move_force))
	
	mouse_velocity = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative / mouse_update_duration
		mouse_update_duration = 0
	
	if Input.is_action_just_pressed("shoot_string"):
		if is_instance_valid(spurt) and spurt.is_anchored():
			spurt.detach()
		
		var mouse := get_global_mouse_position()
		var shoot_direction: Vector2 = (mouse - shoot_origin.global_position).normalized()
		
		spurt = scn_spurt.instance()
		spurt.global_position = shoot_origin.global_position
		spurt.set_velocity(shoot_direction * spurt_velocity)
		spurt.set_anchor(shoot_origin)
		get_tree().get_root().add_child(spurt)
	elif Input.is_action_just_released("shoot_string"):
		if is_instance_valid(spurt) and spurt.is_anchored():
			spurt.detach()
		spurt = null
