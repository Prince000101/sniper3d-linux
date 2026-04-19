extends CharacterBody3D

var mouse_sensitivity = 0.0003

enum { IDLE, AIMING, SCOPED, RELOADING, SHOOTING }
var current_state = IDLE
var is_scoped = false
var can_shoot = true

var weapon_damage = 100
var reload_time = 2.0
var weapon_zoom = 4
var weapon_stability = 50

var normal_fov = 75.0
var current_fov = 75.0

var wind_direction = Vector3(0.5, 0, 0.2)
var wind_speed = 2.0

@onready var camera = $Camera3D
@onready var muzzle = $Camera3D/GunModel/Muzzle
@onready var scope_ui = $CanvasLayer/ScopeUI
@onready var reload_bar = $CanvasLayer/HUD/ReloadBar
@onready var score_label = $CanvasLayer/HUD/TopBar/ScoreLabel
@onready var ammo_label = $CanvasLayer/HUD/TopBar/AmmoLabel
@onready var mission_label = $CanvasLayer/HUD/MissionLabel
@onready var wind_indicator = $CanvasLayer/ScopeUI/WindIndicator
@onready var distance_indicator = $CanvasLayer/ScopeUI/DistanceIndicator

var score = 0
var targets_in_level = 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_visuals()
	set_targets(5)

func setup_visuals():
	if scope_ui:
		scope_ui.visible = false
	if reload_bar:
		reload_bar.visible = false
	update_hud()

func _input(event):
	if event is InputEventMouseMotion:
		var sensitivity = mouse_sensitivity * 15.0
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			shoot()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			toggle_scope()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
		
		if event.button_index == MOUSE_BUTTON_ESCAPE and event.pressed:
			toggle_pause()

func _process(delta):
	update_breathing(delta)
	update_wind_indicator()
	update_distance_indicator()

func update_breathing(delta):
	if not is_scoped:
		var breath = sin(Time.get_ticks_msec() * 0.002) * 0.01
		camera.position.y = breath

func update_wind_indicator():
	if wind_indicator:
		var dir_text = "E" if wind_direction.x > 0 else "W"
		wind_indicator.text = "WIND: %.1f %s" % [wind_speed, dir_text]

func update_distance_indicator():
	if distance_indicator and is_scoped:
		var space_state = get_world_3d().direct_space_state
		var ray_origin = camera.global_position
		var ray_dir = -camera.global_transform.basis.z * 500
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir)
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		if result:
			var dist = ray_origin.distance_to(result.position)
			distance_indicator.text = "DISTANCE: %.1fm" % dist
		else:
			distance_indicator.text = "DISTANCE: ---"

func toggle_pause():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func toggle_scope():
	is_scoped = !is_scoped
	
	if is_scoped:
		current_fov = normal_fov / weapon_zoom
		if scope_ui:
			scope_ui.visible = true
		current_state = SCOPED
	else:
		current_fov = normal_fov
		if scope_ui:
			scope_ui.visible = false
		current_state = IDLE
	
	create_tween().tween_property(camera, "fov", current_fov, 0.15)

func zoom_in():
	var levels = [4, 6, 8, 10, 12]
	var idx = levels.find(weapon_zoom)
	if idx > 0:
		weapon_zoom = levels[idx - 1]
		current_fov = normal_fov / weapon_zoom
		create_tween().tween_property(camera, "fov", current_fov, 0.1)

func zoom_out():
	var levels = [4, 6, 8, 10, 12]
	var idx = levels.find(weapon_zoom)
	if idx < levels.size() - 1:
		weapon_zoom = levels[idx + 1]
		current_fov = normal_fov / weapon_zoom
		create_tween().tween_property(camera, "fov", current_fov, 0.1)

func shoot():
	if current_state == RELOADING or not can_shoot:
		return
	
	can_shoot = false
	current_state = SHOOTING
	
	var recoil_amount = (100 - weapon_stability) * 0.001
	create_tween().tween_property(camera, "rotation_degrees:x", -recoil_amount * 10, 0.05)
	create_tween().tween_property(camera, "rotation_degrees:x", 0, 0.2)
	
	var bullet = load("res://scenes/Bullet.tscn").instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.velocity = -camera.global_transform.basis.z * 300.0
	bullet.wind_force = wind_direction * wind_speed * 0.1
	bullet.damage = weapon_damage
	
	reload_weapon()

func reload_weapon():
	current_state = RELOADING
	if reload_bar:
		reload_bar.visible = true
	
	var tween = create_tween()
	tween.tween_method(func(v): 
		if reload_bar:
			reload_bar.value = v * 100
	, 0.0, 1.0, reload_time)
	tween.tween_callback(func():
		can_shoot = true
		current_state = IDLE if not is_scoped else SCOPED
		if reload_bar:
			reload_bar.visible = false
	)

func update_hud():
	if score_label:
		score_label.text = "KILLS: %d" % score
	if ammo_label:
		ammo_label.text = "READY" if can_shoot else "RELOADING"
	if mission_label:
		mission_label.text = "TARGETS: %d" % targets_in_level

func add_kill():
	score += 1
	targets_in_level = max(0, targets_in_level - 1)
	update_hud()
	
	if targets_in_level <= 0:
		if mission_label:
			mission_label.text = "MISSION COMPLETE!"
			mission_label.modulate = Color.GREEN

func set_targets(count):
	targets_in_level = count
	update_hud()

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)