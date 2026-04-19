extends StaticBody3D

var health = 100
var player_ref = null

func _ready():
	# Add to targets group for counting
	add_to_group("targets")
	# Find player in scene
	player_ref = get_tree().root.find_child("Player", true, false)

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	if player_ref:
		player_ref.add_kill()
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 90.0, 0.5)
	await tween.finished
	queue_free()
