extends StaticBody3D

enum { IDLE, WALKING, RUNNING, ALERT, DEAD }

var current_state = IDLE
var health = 100
var max_health = 100
var move_speed = 1.0

# AI Patrol
var patrol_points = []
var current_patrol_index = 0
var wait_time = 0.0
var target_position = Vector3.ZERO

# Visual
var has_weapon = true
var is_civilian = false # Set to true for bonus missions

@onready var mesh = $MeshInstance3D
@onready var player_ref = null

func _ready():
	find_player()
	setup_patrol()
	add_to_group("targets")

func find_player():
	await get_tree().process_frame
	player_ref = get_tree().root.find_child("Player", true, false)

func setup_patrol():
	patrol_points = [
		global_position,
		global_position + Vector3(5, 0, 0),
		global_position + Vector3(5, 0, 5),
		global_position + Vector3(0, 0, 5)
	]
	target_position = patrol_points[0]

func _process(delta):
	if current_state == DEAD:
		return
	
	process_ai(delta)
	update_animation()

func process_ai(delta):
	# Check if player shot missed nearby (alert)
	if player_ref and player_ref.has_method("is_scoped"):
		var dist_to_player = global_position.distance_to(player_ref.global_position)
		if dist_to_player > 50 and current_state == IDLE:
			current_state = WALKING
			pick_next_patrol_point()

func pick_next_patrol_index():
	if patrol_points.size() > 0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		target_position = patrol_points[current_patrol_index]

func update_animation():
	if mesh and current_state != DEAD:
		var target_dir = global_position.direction_to(target_position)
		if target_dir.length() > 0.1:
			var angle = atan2(target_dir.x, target_dir.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, angle, 0.1)

func take_damage(damage):
	health -= damage
	
	# Knockback effect
	var knockback = Vector3(0, 0.5, -0.5)
	var tween = create_tween()
	tween.tween_property(self, "position", position + knockback, 0.1)
	
	# Blood effect (color change)
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.8, 0.1, 0.1)
		mesh.material_override = mat
	
	if health <= 0:
		die()

func die():
	current_state = DEAD
	
	# Death animation - fall backward
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 90, 0.5)
	tween.tween_callback(queue_free)
	
	if player_ref and player_ref.has_method("add_kill"):
		player_ref.add_kill()

func set_civilian(value):
	is_civilian = value
	if is_civilian:
		# Civilians look different
		if mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.3, 0.3, 0.8)
			mesh.material_override = mat

func set_patrol_path(points: Array):
	patrol_points = points
	if patrol_points.size() > 0:
		target_position = patrol_points[0]
