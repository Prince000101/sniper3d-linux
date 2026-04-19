extends Node3D

var velocity = Vector3.ZERO
var gravity = Vector3(0, -9.8, 0)
var damage = 100
var wind_force = Vector3.ZERO
var lifetime = 5.0
var weapon_range = 500

func _ready():
	set_as_top_level(true)

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	velocity += gravity * delta
	velocity += wind_force * delta
	
	var movement = velocity * delta
	global_position += movement
	
	if velocity.length() > 1.0:
		look_at(global_position + velocity, Vector3.UP)
	
	var dist_from_origin = global_position.length()
	if dist_from_origin > weapon_range:
		queue_free()
		return
	
	var space = get_world_3d().direct_space_state
	if space:
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + movement)
		query.collide_with_bodies = true
		query.collide_with_areas = false
		
		var result = space.intersect_ray(query)
		if result:
			handle_impact(result.position, result.collider)

func handle_impact(pos: Vector3, collider):
	create_impact_effect(pos)
	
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	
	queue_free()

func create_impact_effect(pos):
	var mesh_inst = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.05
	sphere.height = 0.1
	mesh_inst.mesh = sphere
	mesh_inst.position = pos
	get_tree().root.add_child(mesh_inst)
	
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.3)
	mat.emission_energy_multiplier = 3.0
	mesh_inst.material_override = mat
	
	var light = OmniLight3D.new()
	light.omni_range = 2.0
	light.light_energy = 5.0
	light.light_color = Color(1.0, 0.8, 0.3)
	light.position = pos
	get_tree().root.add_child(light)
	
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(mesh_inst):
		mesh_inst.queue_free()
	if is_instance_valid(light):
		light.queue_free()