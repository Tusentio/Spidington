extends KinematicBody2D
class_name StringShot


signal detached
signal hit


const GRAVITY := 1000.0
const DRAG := 0.5
const SHORTENING_COEFFICIENT := 0.8

var anchor: Node2D = null
var velocity := Vector2.ZERO
var tail_velocity := Vector2.ZERO
onready var line := $Line2D


func _process(delta):
	if anchor:
		var space_state := get_world_2d().direct_space_state
		var obstruction := space_state.intersect_ray(global_position, anchor.global_position, [], 0b10)
		if obstruction:
			detach()
		
		line.points[1] = to_local(anchor.global_position)
	else:
		var string_length = line.points[1].length()
		string_length *= pow(SHORTENING_COEFFICIENT, delta)
		
		# Gravity
		tail_velocity += Vector2.DOWN * delta * GRAVITY
		
		# Apply movement and contraints
		var _pos = line.points[1]
		line.points[1] += tail_velocity * delta
		line.points[1] = line.points[1].normalized() * string_length
		tail_velocity = (line.points[1] - _pos) / delta
		
		# Drag
		tail_velocity += -tail_velocity.normalized() * tail_velocity.length_squared() * delta * DRAG


func _physics_process(delta):
	if velocity:
		var collision := move_and_collide(velocity)
		
		if collision:
			velocity = Vector2.ZERO
			emit_signal("hit")


func set_velocity(velocity):
	self.velocity = velocity
	tail_velocity = velocity


func set_anchor(anchor: Node2D):
	self.anchor = anchor


func detach():
	anchor = null
	emit_signal("detached")
