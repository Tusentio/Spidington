extends RigidBody2D

const scn_spurt := preload("res://Scenes/Spurt/Spurt.tscn")

export (float) var spurt_velocity := 10.0
export (float) var move_sensitivity := 0.012
export (float) var max_move_force := 15
export (float) var linear_drag := 0.1
export (float) var angular_drag := 0.1

onready var _shoot_origin := $ShootOrigin
var _spurt: Spurt = null

var _mouse_update_delta := 0.0
var _mouse_velocity := Vector2.ZERO
var _saved_mouse_position := Vector2.ZERO


func _ready():
	load_state()


func _process(delta):
	_mouse_update_delta += delta
	
	if is_instance_valid(_spurt) and _spurt.is_anchored() and _spurt.is_hooked():
		hide_mouse()
	else:
		show_mouse()


func _exit_tree():
	show_mouse()


func _physics_process(delta):
	linear_velocity *= pow(1 / (1 + linear_drag), delta)
	angular_velocity *= pow(1 / (1 + angular_drag), delta)
	
	if is_instance_valid(_spurt) and _spurt.is_anchored() and _spurt.is_hooked():
		var string_normal := (_spurt.global_position - global_position).normalized()
		var directional_force := -_mouse_velocity.dot(string_normal) * move_sensitivity
		apply_impulse(_shoot_origin.global_position - global_position,
			string_normal * clamp(directional_force, 0, max_move_force))
	
	_mouse_velocity = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion and _mouse_update_delta > 0:
		_mouse_velocity = event.relative / _mouse_update_delta
		_mouse_update_delta = 0
	
	if Input.is_action_just_pressed("shoot_string"):
		if is_instance_valid(_spurt) and _spurt.is_anchored():
			_spurt.detach()
		
		var mouse := get_global_mouse_position()
		var shoot_direction: Vector2 = (mouse - _shoot_origin.global_position).normalized()
		
		_spurt = scn_spurt.instance()
		_spurt.global_position = _shoot_origin.global_position
		_spurt.set_velocity(shoot_direction * spurt_velocity)
		_spurt.set_anchor(_shoot_origin)
		get_tree().get_root().add_child(_spurt)
	elif Input.is_action_just_released("shoot_string"):
		if is_instance_valid(_spurt) and _spurt.is_anchored():
			_spurt.detach()
		_spurt = null
	
	if Input.is_action_just_pressed("pause_menu"):
		save_state()


func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			save_state()


func hide_mouse():
	_saved_mouse_position = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _saved_mouse_position:
		get_viewport().warp_mouse(_saved_mouse_position)
		_saved_mouse_position = Vector2.ZERO


func load_state():
	var player_data = PlayerData.read()
	if player_data.saved:
		global_position = player_data.global_position
		rotation = player_data.rotation
		linear_velocity = player_data.linear_velocity
		angular_velocity = player_data.angular_velocity


func save_state():
	var player_data := PlayerData.new()
	player_data.saved = true
	player_data.global_position = global_position
	player_data.rotation = rotation
	player_data.linear_velocity = linear_velocity
	player_data.angular_velocity = angular_velocity
	player_data.save()
