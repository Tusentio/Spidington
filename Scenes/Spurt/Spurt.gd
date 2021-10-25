extends KinematicBody2D
class_name Spurt


signal detached
signal hit


const GRAVITY := 1000.0
const DRAG := 0.001
const SHORTENING_COEFFICIENT := 0.8
const MIN_STRING_LENGTH := 1.0
const MAX_STRING_LENGTH := 100.0

var anchor: Node2D = null
var velocity := Vector2.ZERO
var tail_velocity := Vector2.ZERO
onready var line := $Line2D


func _process(delta):
	var string_length = line.points[1].length()
	
	if is_instance_valid(anchor):
		if string_length > MAX_STRING_LENGTH:
			detach()
			return
		
		var space_state := get_world_2d().direct_space_state
		var obstruction := space_state.intersect_ray(global_position, anchor.global_position, [], 0b10)
		if obstruction:
			detach()
			return
		
		line.points[1] = to_local(anchor.global_position)
	else:
		string_length *= pow(SHORTENING_COEFFICIENT, delta)
		
		if string_length < MIN_STRING_LENGTH:
			queue_free()
			return
		
		# Gravity
		tail_velocity += Vector2.DOWN * delta * GRAVITY
		
		# Apply movement and contraints
		var _pos = line.points[1]
		line.points[1] += tail_velocity * delta
		line.points[1] = line.points[1].normalized() * string_length
		tail_velocity = (line.points[1] - _pos) / delta
		
		# Drag
		var wind_velocity = tail_velocity + velocity
		tail_velocity += -wind_velocity.normalized() * wind_velocity.length_squared() * delta * string_length * DRAG


func _physics_process(delta):
	if velocity:
		var collision := move_and_collide(velocity)
		
		if is_instance_valid(anchor) and collision:
			velocity = Vector2.ZERO
			emit_signal("hit")


func set_velocity(velocity):
	self.velocity = velocity


func set_anchor(anchor: Node2D):
	self.anchor = anchor


func detach():
	anchor = null
	emit_signal("detached")
