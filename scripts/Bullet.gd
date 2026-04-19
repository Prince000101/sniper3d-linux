extends Node3D

var velocity = Vector3.ZERO
var gravity = Vector3(0, -9.8, 0)
var drag_coefficient = 0.001 # Simple air resistance
var lifetime = 5.0
var timer = 0.0

# Global wind reference (could be moved to a singleton)
var wind_force = Vector3(0.5, 0, 0) 

func _process(delta):
	timer += delta
	if timer > lifetime:
		queue_free()
	
	# Realistic Physics: Gravity + Wind + Drag
	var total_force = gravity + wind_force
	velocity += total_force * delta
	velocity *= (1.0 - drag_coefficient) # Drag reduces speed over time
	
	global_position += velocity * delta
	
	if velocity.length() > 0.1:
		look_at(global_position + velocity)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + velocity * delta)
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(100)
			trigger_kill_cam()
		queue_free()

func trigger_kill_cam():
	Engine.time_scale = 0.2
	var tween = create_tween()
	tween.tween_callback(func(): Engine.time_scale = 1.0).set_delay(2.0)
