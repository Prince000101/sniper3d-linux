extends Control

var game_manager = null

func _ready():
	# Try to get or create GameManager
	if not get_node_or_null("/root/GameManager"):
		var gm = load("res://scripts/GameManager.gd").new()
		gm.name = "GameManager"
		get_tree().root.add_child(gm)
	
	game_manager = get_node("/root/GameManager")
	
	# Setup button signals via code to avoid path issues
	var buttons = {
		"CampaignBtn": _on_campaign_pressed,
		"PVEBtn": _on_pve_pressed,
		"PVPBtn": _on_pvp_pressed,
		"ArmoryBtn": _on_armory_pressed,
		"QuitBtn": _on_quit_pressed
	}
	
	for btn_name in buttons:
		var btn = find_child(btn_name, true, false)
		if btn:
			btn.pressed.connect(buttons[btn_name])
	
	update_currency_display()

func update_currency_display():
	if game_manager:
		var coins_lbl = find_child("CoinsLabel", true, false)
		var diamond_lbl = find_child("DiamondsLabel", true, false)
		if coins_lbl:
			coins_lbl.text = "COINS: %d" % game_manager.coins
		if diamond_lbl:
			diamond_lbl.text = "DIAMONDS: %d" % game_manager.diamonds

func _on_campaign_pressed():
	start_game()

func _on_pve_pressed():
	start_game()

func _on_pvp_pressed():
	# PVP coming soon - just start game for now
	start_game()

func _on_armory_pressed():
	# Armory - just start game for now
	start_game()

func _on_quit_pressed():
	get_tree().quit()

func start_game():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")