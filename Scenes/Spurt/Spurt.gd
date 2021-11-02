extends KinematicBody2D
class_name Spurt

const GRAVITY := 1000.0
const DRAG := 0.004
const SHORTENING_COEFFICIENT := 0.2
const MIN_STRING_LENGTH := 1.0
const MAX_STRING_LENGTH := 150.0
const OBSTACLE_LEEWAY := 3.0

var anchor: Node2D = null
var velocity := Vector2.ZERO
var tail_velocity := Vector2.ZERO
onready var line := $Line2D


func _process(delta):
	var string_length = length()
	
	if is_anchored():
		if string_length > MAX_STRING_LENGTH:
			if is_hooked():
				$SnapSound.play()
			detach()
			return
		
		var space_state := get_world_2d().direct_space_state
		var obstruction := space_state.intersect_ray(
			anchor.global_position - OBSTACLE_LEEWAY * normal(),
			global_position, [], 0b10)
		if obstruction:
			$SnapSound.play()
			line.points[1] = to_local(obstruction.position)
			detach()
			return
		
		line.points[1] = to_local(anchor.global_position)
	elif is_hooked():
		if string_length < MIN_STRING_LENGTH:
			queue_free()
			return
		
		string_length *= pow(SHORTENING_COEFFICIENT, delta)
		
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
		
		if collision:
			if is_anchored():
				var collider = collision.collider
				if collider is Hook:
					collider.anchored()
				else:
					detach()
			
			set_velocity(Vector2.ZERO)


func set_velocity(velocity: Vector2):
	self.velocity = velocity


func set_anchor(anchor: Node2D):
	self.anchor = anchor


func length() -> float:
	return line.points[1].length()


func normal() -> Vector2:
	return line.points[1].normalized()


func detach():
	if is_anchored():
		anchor = null


func is_hooked():
	return velocity == Vector2.ZERO


func is_anchored():
	return is_instance_valid(anchor)
