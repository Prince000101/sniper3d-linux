extends StaticBody3D

enum { IDLE, WALKING, RUNNING, ALERT, DEAD }

var current_state = IDLE
var health = 100
var max_health = 100
var move_speed = 1.0

var patrol_points = []
var current_patrol_index = 0
var target_position = Vector3.ZERO

@onready var mesh = $MeshInstance3D
var player_ref = null

func _ready():
	add_to_group("targets")
	find_player()

func find_player():
	await get_tree().process_frame
	player_ref = get_tree().root.find_child("Player", true, false)

func _process(delta):
	if current_state == DEAD:
		return
	
	process_ai(delta)
	update_animation()

func process_ai(delta):
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

func take_damage(dmg):
	health -= dmg
	
	var knockback = Vector3(0, 0.5, -0.5)
	var tween = create_tween()
	tween.tween_property(self, "position", position + knockback, 0.1)
	
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.8, 0.1, 0.1)
		mesh.material_override = mat
	
	if health <= 0:
		die()

func die():
	current_state = DEAD
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 90, 0.5)
	tween.tween_callback(queue_free)
	
	if player_ref and player_ref.has_method("add_kill"):
		player_ref.add_kill()

func set_patrol_path(points: Array):
	patrol_points = points
	if patrol_points.size() > 0:
		target_position = patrol_points[0]