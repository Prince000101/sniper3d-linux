extends Control

@onready var campaign_btn = $CampaignBtn
@onready var pve_btn = $PVEBtn
@onready var pvp_btn = $PVPBtn
@onready var armory_btn = $ArmoryBtn
@onready var quit_btn = $QuitBtn
@onready var coins_label = $CurrencyPanel/CoinsLabel
@onready var diamonds_label = $CurrencyPanel/DiamondsLabel

var game_manager

func _ready():
	game_manager = get_node("/root/GameManager")
	
	# Connect buttons
	campaign_btn.pressed.connect(_on_campaign_pressed)
	pve_btn.pressed.connect(_on_pve_pressed)
	pvp_btn.pressed.connect(_on_pvp_pressed)
	armory_btn.pressed.connect(_on_armory_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	update_currency_display()

func update_currency_display():
	if game_manager and coins_label and diamonds_label:
		coins_label.text = "COINS: %d" % game_manager.coins
		diamonds_label.text = "DIAMONDS: %d" % game_manager.diamonds

func _on_campaign_pressed():
	start_mission(1)

func _on_pve_pressed():
	show_mission_select()

func _on_pvp_pressed():
	# PVP coming soon - show message
	pvp_btn.text = "COMING SOON"

func _on_armory_pressed():
	show_armory()

func _on_quit_pressed():
	get_tree().quit()

func start_mission(level):
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func show_mission_select():
	# Would show mission selection panel
	start_mission(game_manager.selected_mission)

func show_armory():
	# Would show weapon shop
	armory_btn.text = "ARMORY"