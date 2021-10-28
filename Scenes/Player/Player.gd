extends RigidBody2D

const scn_spurt := preload("res://Scenes/Spurt/Spurt.tscn")

export (float) var spurt_velocity := 10.0
export (float) var move_sensitivity := 0.012
export (float) var max_move_force := 15
export (float) var linear_drag := 0.1
export (float) var angular_drag := 0.1

onready var shoot_origin := $ShootOrigin
var spurt: Spurt = null

var mouse_update_delta := 0.0
var mouse_velocity := Vector2.ZERO
var saved_mouse_position := Vector2.ZERO
var mouse_hidden := false


func _ready():
	load_state()


func _process(delta):
	mouse_update_delta += delta
	
	if is_instance_valid(spurt) and spurt.is_anchored() and spurt.is_hooked():
		hide_mouse()
	else:
		show_mouse()


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
	if mouse_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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


func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			save_state()


func hide_mouse():
	if not mouse_hidden:
		mouse_hidden = true
		saved_mouse_position = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func show_mouse():
	if mouse_hidden:
		mouse_hidden = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if saved_mouse_position:
			get_viewport().warp_mouse(saved_mouse_position)
			saved_mouse_position = Vector2.ZERO


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
