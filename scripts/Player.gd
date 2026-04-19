extends CharacterBody3D

# ==== SNIPER 3D STYLE CONTROLS ====
var mouse_sensitivity = 0.001

# States
enum { IDLE, AIMING, SCOPED, RELOADING, SHOOTING }
var current_state = IDLE
var is_scoped = false
var can_shoot = true
var breath_held = false

# Weapon Stats (from GameManager)
var current_weapon_index = 0
var weapon_damage = 100
var reload_time = 2.0
var weapon_zoom = 4
var weapon_stability = 50

# FOV
var normal_fov = 75.0
var current_fov = 75.0

# Environment
var wind_direction = Vector3(0.5, 0, 0.2)
var wind_speed = 2.0

@onready var camera = $Camera3D
@onready var gun_model = $Camera3D/GunModel
@onready var muzzle = $Camera3D/GunModel/Muzzle
@onready var scope_ui = $CanvasLayer/ScopeUI
@onready var hud = $CanvasLayer/HUD
@onready var reload_bar = $CanvasLayer/HUD/ReloadBar
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var ammo_label = $CanvasLayer/HUD/AmmoLabel
@onready var mission_label = $CanvasLayer/HUD/MissionLabel
@onready var wind_indicator = $CanvasLayer/ScopeUI/WindIndicator

var target_ref = null
var score = 0
var targets_in_level = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	load_weapon_stats()
	setup_visuals()

func setup_visuals():
	if scope_ui: scope_ui.visible = false
	if reload_bar: reload_bar.visible = false
	update_hud()

func load_weapon_stats():
	var game_manager = get_node("/root/GameManager")
	var weapon = game_manager.get_current_weapon()
	weapon_damage = weapon.damage
	reload_time = weapon.reload
	weapon_zoom = weapon.zoom
	weapon_stability = weapon.stability

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Sniper 3D style smooth rotation
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity * 10))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity * 10))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		# Add stability based on breath hold
		var stability_mod = 1.0
		if breath_held:
			stability_mod = 0.3
		elif is_scoped:
			stability_mod = 0.5
		
		# Subtle camera sway
		var time = Time.get_ticks_msec() * 0.001
		camera.rotation.z = sin(time * 2) * 0.01 * stability_mod

func _process(delta):
	update_breathing(delta)
	update_wind_indicator()
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
	
	if Input.is_action_just_pressed("scope"):
		toggle_scope()
	
	if Input.is_action_just_pressed("reload") and not can_shoot:
		reload_weapon()
	
	if Input.is_action_just_pressed("toggle_zoom"):
		cycle_zoom()
	
	# Update scope sway
	if is_scoped and not breath_held:
		var sway_offset = Vector2(
			sin(Time.get_ticks_msec() * 0.002) * 0.5,
			cos(Time.get_ticks_msec() * 0.0015) * 0.3
		)
		camera.rotation.z = sway_offset.x * 0.02

func update_breathing(delta):
	# Idle breathing animation when not scoped
	if not is_scoped:
		var breath = sin(Time.get_ticks_msec() * 0.002) * 0.01
		camera.position.y = breath

func update_wind_indicator():
	if wind_indicator:
		var wind_text = "WIND: "
		var speed_text = "%.1f" % wind_speed
		var dir_text = ""
		if abs(wind_direction.x) > abs(wind_direction.z):
			dir_text = "E" if wind_direction.x > 0 else "W"
		else:
			dir_text = "S" if wind_direction.z > 0 else "N"
		wind_indicator.text = wind_text + speed_text + " " + dir_text

func toggle_scope():
	is_scoped = !is_scoped
	
	if is_scoped:
		current_fov = normal_fov / weapon_zoom
		scope_ui.visible = true
		current_state = SCOPED
	else:
		current_fov = normal_fov
		scope_ui.visible = false
		current_state = IDLE
	
	create_tween().tween_property(camera, "fov", current_fov, 0.15)

func cycle_zoom():
	var zoom_levels = [4, 6, 8, 10, 12]
	var current_idx = zoom_levels.find(weapon_zoom * 2)
	if current_idx == -1:
		current_idx = 0
	current_idx = (current_idx + 1) % zoom_levels.size()
	current_fov = normal_fov / zoom_levels[current_idx]
	create_tween().tween_property(camera, "fov", current_fov, 0.1)

func reload_weapon():
	if not can_shoot:
		return
	
	current_state = RELOADING
	can_shoot = false
	reload_bar.visible = true
	
	var tween = create_tween()
	tween.tween_method(set_reload_progress, 0.0, 1.0, reload_time)
	tween.tween_callback(func():
		can_shoot = true
		current_state = IDLE if not is_scoped else SCOPED
		reload_bar.visible = false
	)

func set_reload_progress(value):
	if reload_bar:
		reload_bar.value = value * 100

func shoot():
	if current_state == RELOADING:
		return
	
	can_shoot = false
	current_state = SHOOTING
	
	# Recoil
	var recoil_amount = (100 - weapon_stability) * 0.001
	create_tween().tween_property(camera, "rotation_degrees:x", -recoil_amount * 10, 0.05)
	create_tween().tween_property(camera, "rotation_degrees:x", 0, 0.2)
	
	# Spawn bullet
	var bullet = load("res://scenes/Bullet.tscn").instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.velocity = -camera.global_transform.basis.z * 300.0
	bullet.wind_force = wind_direction * wind_speed * 0.1
	bullet.damage = weapon_damage
	
	# Muzzle flash
	if muzzle:
		var flash = OmniLight3D.new()
		flash.omni_range = 2.0
		flash.omni_energy = 5.0
		flash.light_color = Color.ORANGE
		muzzle.add_child(flash)
		await get_tree().create_timer(0.05).timeout
		flash.queue_free()
	
	# Reload after shot
	reload_weapon()

func update_hud():
	if score_label:
		score_label.text = "KILLS: %d" % score
	if ammo_label:
		ammo_label.text = "READY" if can_shoot else "RELOADING..."
	if mission_label:
		mission_label.text = "TARGETS: %d" % targets_in_level

func add_kill():
	score += 1
	targets_in_level -= 1
	update_hud()
	
	if targets_in_level <= 0:
		complete_level()

func complete_level():
	var game_manager = get_node("/root/GameManager")
	game_manager.complete_mission(true)
	mission_label.text = "MISSION COMPLETE!"
	mission_label.modulate = Color.GREEN

func set_targets(count):
	targets_in_level = count
	update_hud()

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)