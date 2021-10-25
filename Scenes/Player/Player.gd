extends Node2D

const scn_spurt := preload("res://Scenes/Spurt/Spurt.tscn")

export (float) var string_speed := 500.0
onready var shoot_origin := $ShootOrigin
var _is_ready := false
var spurt: Spurt = null


func _ready():
	_is_ready = true


func _input(event):
	if Input.is_action_just_pressed("shoot_string"):
		if is_instance_valid(spurt):
			spurt.disconnect("hit", self, "_shot_hit")
			spurt.detach()
		
		var mouse := get_global_mouse_position()
		var shoot_direction: Vector2 = (mouse - shoot_origin.global_position).normalized()
		
		spurt = scn_spurt.instance()
		
		spurt.global_position = shoot_origin.global_position
		spurt.set_velocity(shoot_direction * 10)
		spurt.set_anchor(shoot_origin)
		
		spurt.connect("hit", self, "_shot_hit")
		
		get_tree().get_root().add_child(spurt)

func _shot_hit():
	spurt.detach()
