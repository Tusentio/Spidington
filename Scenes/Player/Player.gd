extends Node2D


const string_shot := preload("res://Scenes/String/String.tscn")

export (float) var string_speed := 500.0
onready var shoot_origin := $ShootOrigin
var _is_ready := false
var shot: StringShot = null


func _ready():
	_is_ready = true


func _input(event):
	if Input.is_action_just_pressed("shoot_string"):
		if shot:
			shot.disconnect("hit", self, "_shot_hit")
			shot.detach()
		
		var mouse := get_global_mouse_position()
		var shoot_direction: Vector2 = (mouse - shoot_origin.global_position).normalized()
		
		shot = string_shot.instance()
		
		shot.global_position = shoot_origin.global_position
		shot.set_velocity(shoot_direction * 1)
		shot.set_anchor(shoot_origin)
		
		shot.connect("hit", self, "_shot_hit")
		
		get_tree().get_root().add_child(shot)

func _shot_hit():
	shot.detach()
