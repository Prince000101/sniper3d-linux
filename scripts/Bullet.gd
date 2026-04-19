extends Node3D

var velocity = Vector3.ZERO
var gravity = Vector3(0, -5.0, 0) # Lighter gravity for arcade feel
var damage = 100
var wind_force = Vector3.ZERO
var lifetime = 3.0

var impact_particle = null

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	# Arcade-style ballistics (minimal drop)
	velocity += gravity * delta
	velocity += wind_force * delta
	
	var movement = velocity * delta
	global_position += movement
	
	# Orient bullet direction
	if velocity.length() > 1.0:
		look_at(global_position + velocity, Vector3.UP)
	
	# Simple collision check
	var space = get_world_3d().direct_space_state
	if space:
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + movement)
		query.collide_with_bodies = true
		query.collide_with_areas = false
		
		var result = space.intersect_ray(query)
		if result:
			handle_impact(result.position, result.collider)

func handle_impact(pos: Vector3, collider):
	# Create impact effect
	create_impact_effect(pos)
	
	# Damage target
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	
	queue_free()

func create_impact_effect(pos):
	# Simple flash effect
	var light = OmniLight3D.new()
	light.omni_range = 1.0
	light.omni_energy = 3.0
	light.light_color = Color(1.0, 0.8, 0.3)
	light.position = Vector3.ZERO
	add_child(light)
	
	# Particle would go here in full version
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		pass # Light auto-free when parent freed