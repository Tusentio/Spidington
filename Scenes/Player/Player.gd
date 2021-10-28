extends RigidBody2D

const scn_spurt := preload("res://Scenes/Spurt/Spurt.tscn")

export (float) var spurt_velocity := 10.0
export (float) var move_sensitivity := 0.012
export (float) var max_move_force := 15
export (float) var linear_drag := 0.1
export (float) var angular_drag := 0.1

onready var timer_label := $CanvasLayer/TimerLabel
var time_major: int = 0
var time_minor: float = 0.0

onready var shoot_origin := $ShootOrigin
var spurt: Spurt = null

var mouse_update_delta := 0.0
var mouse_velocity := Vector2.ZERO
var saved_mouse_position := Vector2.ZERO

const DEBUG_SPEED := 64.0
const DEBUG_ACCELERATION := 16.0

var debug_mode := false
var debug_speed := DEBUG_SPEED


func _ready():
	load_state()


func _process(delta):
	mouse_update_delta += delta
	
	time_minor += delta
	if time_minor > 1:
		var major_inc := int(time_minor)
		time_major += major_inc
		time_minor -= major_inc
	timer_label.text = String(get_seconds()) + "." + String(get_millis()).pad_zeros(3)
	
	if is_instance_valid(spurt) and spurt.is_anchored() and spurt.is_hooked():
		hide_mouse()
	else:
		show_mouse()
	
	if debug_mode:
		var debug_move := ((Vector2.LEFT if Input.is_action_pressed("debug_left") else Vector2.ZERO) +
			(Vector2.RIGHT if Input.is_action_pressed("debug_right") else Vector2.ZERO) +
			(Vector2.UP if Input.is_action_pressed("debug_up") else Vector2.ZERO) +
			(Vector2.DOWN if Input.is_action_pressed("debug_down") else Vector2.ZERO))
		
		if debug_move:
			translate(debug_move.normalized() * debug_speed * delta)
			debug_speed += DEBUG_ACCELERATION * delta
		else:
			debug_speed = DEBUG_SPEED


func _exit_tree():
	show_mouse()


func _physics_process(delta):
	linear_velocity *= pow(1 / (1 + linear_drag), delta)
	angular_velocity *= pow(1 / (1 + angular_drag), delta)
	
	if is_instance_valid(spurt) and spurt.is_anchored() and spurt.is_hooked():
		var string_normal := (spurt.global_position - global_position).normalized()
		var directional_force := -mouse_velocity.dot(string_normal) * move_sensitivity
		apply_impulse(shoot_origin.global_position - global_position,
			string_normal * clamp(directional_force, 0, max_move_force))
	
	mouse_velocity = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion and mouse_update_delta > 0:
		mouse_velocity = event.relative / mouse_update_delta
		mouse_update_delta = 0
	
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
	
	if Input.is_action_just_pressed("pause_menu"):
		save_state()
	
	if Input.is_action_just_pressed("toggle_debug_mode") and OS.is_debug_build():
		debug_mode = !debug_mode
		mode = MODE_STATIC if debug_mode else MODE_RIGID


func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			save_state()


func get_seconds() -> int:
	return time_major


func get_millis() -> int:
	return int(time_minor * 1000)


func hide_mouse():
	if not saved_mouse_position:
		saved_mouse_position = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func show_mouse():
	if saved_mouse_position:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().warp_mouse(saved_mouse_position)
		saved_mouse_position = Vector2.ZERO


func load_state():
	var player_data: PlayerData = PlayerData.read()
	
	if player_data.saved:
		global_position = player_data.global_position
		rotation = player_data.rotation
		linear_velocity = player_data.linear_velocity
		angular_velocity = player_data.angular_velocity
		
		time_major = player_data.time_major
		time_minor = player_data.time_minor


func save_state():
	var player_data := PlayerData.new()
	
	player_data.saved = true
	player_data.global_position = global_position
	player_data.rotation = rotation
	player_data.linear_velocity = linear_velocity
	player_data.angular_velocity = angular_velocity
	
	player_data.time_major = time_major
	player_data.time_minor = time_minor
	
	player_data.save()
