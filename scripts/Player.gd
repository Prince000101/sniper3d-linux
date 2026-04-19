extends CharacterBody3D

# --- Game State ---
var score = 0
var targets_remaining = 0
var game_won = false

# --- Settings ---
var is_scoped = false
var is_rangefinding = false
var can_shoot = true
var bolt_action_time = 1.5
var mouse_sensitivity = 0.001 # Lower default

var normal_fov = 75.0
var scoped_fov = 10.0
var wind_vector = Vector3(0.8, 0, 0.2)

# --- Node References ---
@onready var camera = $Camera3D
@onready var gun_model = $Camera3D/GunModel
@onready var rangefinder_model = $Camera3D/RangefinderModel
@onready var scope_ui = $CanvasLayer/ScopeUI
@onready var info_ui = $CanvasLayer/InfoUI
@onready var distance_label = $CanvasLayer/InfoUI/DistanceLabel
@onready var wind_label = $CanvasLayer/InfoUI/WindLabel
@onready var settings_menu = $CanvasLayer/SettingsMenu
@onready var default_crosshair = $CanvasLayer/DefaultCrosshair
@onready var score_label = $CanvasLayer/ScoreUI/ScoreLabel
@onready var mission_label = $CanvasLayer/ScoreUI/MissionLabel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_ui()
	count_targets()

func setup_ui():
	if scope_ui: scope_ui.visible = false
	if info_ui: info_ui.visible = false
	if settings_menu: settings_menu.visible = false
	if rangefinder_model: rangefinder_model.visible = false
	update_score_display()

func count_targets():
	targets_remaining = 0
	var targets = get_tree().get_nodes_in_group("targets")
	targets_remaining = targets.size()
	update_mission_display()

func update_score_display():
	if score_label:
		score_label.text = "KILLS: %d" % score

func update_mission_display():
	if mission_label:
		mission_label.text = "TARGETS REMAINING: %d" % targets_remaining

# --- PRO CAMERA SYSTEM ---
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Professional FPS rotation: use relative mouse movement, not velocity
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity * 10.0))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity * 10.0))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	if Input.is_action_just_pressed("settings"):
		toggle_settings()

	if settings_menu and settings_menu.visible:
		return

	# Camera Sway when scoped
	if is_scoped:
		var sway_x = sin(Time.get_ticks_msec() * 0.002) * 0.02
		var sway_y = cos(Time.get_ticks_msec() * 0.001) * 0.02
		camera.rotation.z = sway_x
		camera.position.x = sway_y

	if Input.is_action_just_pressed("scope"):
		toggle_scope()

	if Input.is_action_just_pressed("rangefinder"):
		toggle_rangefinder()

	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

	if is_rangefinding:
		update_rangefinder_info()

func toggle_scope():
	is_scoped = !is_scoped
	is_rangefinding = false
	if info_ui: info_ui.visible = false
	if rangefinder_model: rangefinder_model.visible = false
	if scope_ui: scope_ui.visible = is_scoped
	if default_crosshair: default_crosshair.visible = !is_scoped
	
	var target_fov = scoped_fov if is_scoped else normal_fov
	create_tween().tween_property(camera, "fov", target_fov, 0.1)

func toggle_rangefinder():
	is_rangefinding = !is_rangefinding
	is_scoped = false
	if scope_ui: scope_ui.visible = false
	if info_ui: info_ui.visible = is_rangefinding
	if rangefinder_model: rangefinder_model.visible = is_rangefinding
	if default_crosshair: default_crosshair.visible = !is_rangefinding
	
	var target_fov = 40.0 if is_rangefinding else normal_fov
	create_tween().tween_property(camera, "fov", target_fov, 0.1)

func toggle_settings():
	if not settings_menu: return
	settings_menu.visible = !settings_menu.visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if settings_menu.visible else Input.MOUSE_MODE_CAPTURED)

func update_rangefinder_info():
	if not info_ui: return
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_transform.basis.z * 1000)
	var result = space_state.intersect_ray(query)
	
	if result:
		var dist = camera.global_position.distance_to(result.position)
		distance_label.text = "DISTANCE: %.1fm" % dist
	else:
		distance_label.text = "DISTANCE: ---"
	
	wind_label.text = "WIND: %.1f m/s %s" % [wind_vector.length(), get_wind_direction_text()]

func get_wind_direction_text():
	if abs(wind_vector.x) > abs(wind_vector.z):
		return "EAST" if wind_vector.x > 0 else "WEST"
	return "SOUTH" if wind_vector.z > 0 else "NORTH"

func shoot():
	can_shoot = false
	# Recoil
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:x", camera.rotation_degrees.x + 3.0, 0.05)
	tween.tween_property(camera, "rotation_degrees:x", camera.rotation_degrees.x, 0.3)
	
	var bullet_scene = load("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = camera.global_transform
	bullet.wind_force = wind_vector
	bullet.velocity = -camera.global_transform.basis.z * 250.0
	
	await get_tree().create_timer(bolt_action_time).timeout
	can_shoot = true

func add_kill():
	score += 1
	targets_remaining -= 1
	update_score_display()
	update_mission_display()
	if targets_remaining <= 0:
		win_game()

func win_game():
	game_won = true
	if mission_label:
		mission_label.text = "MISSION COMPLETE!"
		mission_label.modulate = Color.GREEN

func _on_sensitivity_slider_value_changed(value):
	mouse_sensitivity = value * 0.001
