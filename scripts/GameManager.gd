extends Node

enum GameState { MENU, PLAYING, PAUSED, MISSION_COMPLETE, GAME_OVER }

var current_state = GameState.MENU
var current_level = 1
var coins = 0
var diamonds = 0
var current_weapon = 0
var mouse_sensitivity = 0.0001

# Weapons: [name, damage, reload_time, mag_size, zoom, stability, price]
var weapons = [
	{"name": "Hunter Rifle", "damage": 100, "reload": 2.0, "mag": 1, "zoom": 4, "stability": 50, "price": 0},
	{"name": "M24 Sniper", "damage": 250, "reload": 1.8, "mag": 1, "zoom": 6, "stability": 65, "price": 500},
	{"name": "AWP Magnum", "damage": 400, "reload": 1.5, "mag": 1, "zoom": 8, "stability": 80, "price": 1500},
	{"name": "Barrett M82", "damage": 600, "reload": 1.2, "mag": 1, "zoom": 10, "stability": 90, "price": 5000},
	{"name": "MSR Rifle", "damage": 850, "reload": 1.0, "mag": 1, "zoom": 12, "stability": 95, "price": 15000}
]

var selected_mission = 1
var missions_completed = 0

# Missions: [level, targets, location, difficulty]
var missions = [
	{"level": 1, "targets": 1, "location": "City Rooftop", "difficulty": 1},
	{"level": 2, "targets": 2, "location": "Warehouse", "difficulty": 2},
	{"level": 3, "targets": 3, "location": "Military Base", "difficulty": 3},
	{"level": 4, "targets": 3, "location": "Desert Camp", "difficulty": 4},
	{"level": 5, "targets": 4, "location": "Urban Streets", "difficulty": 5},
	{"level": 6, "targets": 5, "location": "Forest Hideout", "difficulty": 6},
	{"level": 7, "targets": 5, "location": "Harbor", "difficulty": 7},
	{"level": 8, "targets": 6, "location": "Mountain Base", "difficulty": 8},
	{"level": 9, "targets": 7, "location": "City Center", "difficulty": 9},
	{"level": 10, "targets": 10, "location": "Final Mission", "difficulty": 10}
]

signal state_changed(new_state)
signal weapon_changed(weapon_index)
signal mission_changed(mission_index)
signal currency_updated(coins, diamonds)
signal level_started(level_num)
signal mission_completed(success)

func _ready():
	load_game()

func start_game():
	current_state = GameState.PLAYING
	state_changed.emit(current_state)
	level_started.emit(current_level)

func pause_game():
	current_state = GameState.PAUSED
	state_changed.emit(current_state)

func resume_game():
	current_state = GameState.PLAYING
	state_changed.emit(current_state)

func complete_mission(success):
	missions_completed += 1
	if success:
		var mission = missions[selected_mission - 1]
		var reward = mission.difficulty * 100
		coins += reward
		current_level += 1
		mission_completed.emit(true)
	save_game()
	current_state = GameState.MISSION_COMPLETE
	state_changed.emit(current_state)

func select_weapon(index):
	if index < weapons.size():
		current_weapon = index
		weapon_changed.emit(index)
		save_game()

func select_mission(index):
	selected_mission = index
	mission_changed.emit(index)

func buy_weapon(index):
	var weapon = weapons[index]
	if coins >= weapon.price:
		coins -= weapon.price
		current_weapon = index
		weapon_changed.emit(index)
		currency_updated.emit(coins, diamonds)
		save_game()

func get_current_weapon():
	return weapons[current_weapon]

func save_game():
	var save_data = {
		"coins": coins,
		"diamonds": diamonds,
		"current_weapon": current_weapon,
		"current_level": current_level,
		"missions_completed": missions_completed
	}
	var file = FileAccess.open("user://game_save.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://game_save.dat"):
		var file = FileAccess.open("user://game_save.dat", FileAccess.READ)
		var json = JSON.parse_string(file.get_as_string())
		if json:
			coins = json.get("coins", 0)
			diamonds = json.get("diamonds", 0)
			current_weapon = json.get("current_weapon", 0)
			current_level = json.get("current_level", 1)
			missions_completed = json.get("missions_completed", 0)
		file.close()

func return_to_menu():
	current_state = GameState.MENU
	state_changed.emit(current_state)