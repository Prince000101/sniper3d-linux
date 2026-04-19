extends Control

var game_manager = null
var sensitivity_value = 0.3

func _ready():
	if not get_node_or_null("/root/GameManager"):
		var gm = load("res://scripts/GameManager.gd").new()
		gm.name = "GameManager"
		get_tree().root.add_child(gm)
	
	game_manager = get_node("/root/GameManager")
	
	var button_connections = {
		"CampaignBtn": _on_campaign_pressed,
		"PVEBtn": _on_pve_pressed,
		"SettingsBtn": _on_settings_pressed,
		"QuitBtn": _on_quit_pressed,
		"CloseSettings": _on_close_settings_pressed
	}
	
	for btn_name in button_connections:
		var btn = find_child(btn_name, true, false)
		if btn:
			btn.pressed.connect(button_connections[btn_name]
	
	var slider = find_child("SensitivitySlider", true, false)
	if slider:
		slider.value_changed.connect(_on_sensitivity_changed)
		slider.value = sensitivity_value
	
	update_currency_display()

func update_currency_display():
	if game_manager:
		var coins_lbl = find_child("CoinsLabel", true, false)
		var diamond_lbl = find_child("DiamondsLabel", true, false)
		if coins_lbl:
			coins_lbl.text = "COINS: %d" % game_manager.coins
		if diamond_lbl:
			diamond_lbl.text = "DIAMONDS: %d" % game_manager.diamonds

func _on_sensitivity_changed(value):
	sensitivity_value = value
	var value_label = find_child("SensitivityValue", true, false)
	if value_label:
		value_label.text = "%.1f" % value

func _on_campaign_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_pve_pressed():
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")

func _on_settings_pressed():
	var panel = find_child("SettingsPanel", true, false)
	if panel:
		panel.visible = true

func _on_close_settings_pressed():
	var panel = find_child("SettingsPanel", true, false)
	if panel:
		panel.visible = false

func _on_quit_pressed():
	get_tree().quit()