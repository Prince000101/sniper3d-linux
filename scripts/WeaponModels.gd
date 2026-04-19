extends Node3D

# Procedurally generated sniper rifle models
# This creates detailed low-poly weapons using built-in primitives

@export var weapon_type: String = "KAR98"
@export var weapon_color: Color = Color(0.15, 0.15, 0.15)

func _ready():
	build_weapon()

func build_weapon():
	# Clear existing
	for child in get_children():
		child.queue_free()
	
	match weapon_type:
		"KAR98":
			build_kar98()
		"AWP":
			build_awp()
		"M24":
			build_m24()
		"MSR":
			build_msr()
		_:
			build_kar98()

func build_kar98():
	# Main body
	var receiver = create_box(Vector3(0.08, 0.08, 0.4), weapon_color)
	receiver.position = Vector3(0, 0, 0.1)
	add_child(receiver)
	
	# Barrel
	var barrel = create_cylinder(0.015, 0.8)
	barrel.position = Vector3(0, 0, 0.5)
	barrel.rotation_degrees.x = 90
	add_child(barrel)
	
	# Stock
	var stock = create_box(Vector3(0.05, 0.08, 0.5), Color(0.3, 0.2, 0.1))
	stock.position = Vector3(0, 0, -0.2)
	stock.rotation_degrees.x = 15
	add_child(stock)
	
	# Scope mount
	var mount = create_box(Vector3(0.03, 0.03, 0.15), Color(0.1, 0.1, 0.1))
	mount.position = Vector3(0, 0.1, 0.1)
	add_child(mount)
	
	# Scope
	var scope = create_cylinder(0.02, 0.15)
	scope.position = Vector3(0, 0.13, 0.1)
	scope.rotation_degrees.x = 90
	add_child(scope)
	
	# Bipod legs
	var leg_l = create_cylinder(0.01, 0.15)
	leg_l.position = Vector3(-0.05, -0.05, -0.1)
	leg_l.rotation_degrees.z = 30
	add_child(leg_l)
	
	var leg_r = create_cylinder(0.01, 0.15)
	leg_r.position = Vector3(0.05, -0.05, -0.1)
	leg_r.rotation_degrees.z = -30
	add_child(leg_r)
	
	# Magazine/internal tube
	var mag_tube = create_cylinder(0.015, 0.25)
	mag_tube.position = Vector3(0, -0.03, 0.15)
	mag_tube.rotation_degrees.x = 90
	mag_tube.material_override = create_material(Color(0.2, 0.2, 0.2))
	add_child(mag_tube)

func build_awp():
	# Magnum body - thicker
	var receiver = create_box(Vector3(0.1, 0.1, 0.5), weapon_color)
	receiver.position = Vector3(0, 0, 0.15)
	add_child(receiver)
	
	# Long heavy barrel
	var barrel = create_cylinder(0.02, 1.0)
	barrel.position = Vector3(0, 0, 0.6)
	barrel.rotation_degrees.x = 90
	add_child(barrel)
	
	# Tactical stock
	var stock = create_box(Vector3(0.06, 0.1, 0.6), Color(0.2, 0.2, 0.2))
	stock.position = Vector3(0, 0, -0.15)
	stock.rotation_degrees.x = 10
	add_child(stock)
	
	# Large scope
	var mount = create_box(Vector3(0.04, 0.04, 0.2), Color(0.1, 0.1, 0.1))
	mount.position = Vector3(0, 0.14, 0.15)
	add_child(mount)
	
	var scope = create_cylinder(0.025, 0.25)
	scope.position = Vector3(0, 0.18, 0.15)
	scope.rotation_degrees.x = 90
	add_child(scope)
	
	# Muzzle brake
	var brake = create_cylinder(0.025, 0.08)
	brake.position = Vector3(0, 0, 1.1)
	brake.rotation_degrees.x = 90
	add_child(brake)

func build_m24():
	# Classic wooden stock style
	var receiver = create_box(Vector3(0.07, 0.07, 0.35), weapon_color)
	receiver.position = Vector3(0, 0, 0.1)
	add_child(receiver)
	
	# Medium barrel
	var barrel = create_cylinder(0.018, 0.65)
	barrel.position = Vector3(0, 0, 0.5)
	barrel.rotation_degrees.x = 90
	add_child(barrel)
	
	# Wooden stock with cheek rest
	var stock = create_box(Vector3(0.05, 0.09, 0.45), Color(0.4, 0.25, 0.1))
	stock.position = Vector3(0, 0, -0.15)
	add_child(stock)
	
	# Cheek rest
	var cheek = create_box(Vector3(0.04, 0.03, 0.15), Color(0.35, 0.2, 0.1))
	cheek.position = Vector3(0, 0.06, -0.1)
	add_child(cheek)
	
	# Scope
	var mount = create_box(Vector3(0.03, 0.03, 0.12), Color(0.1, 0.1, 0.1))
	mount.position = Vector3(0, 0.11, 0.08)
	add_child(mount)
	
	var scope = create_cylinder(0.02, 0.18)
	scope.position = Vector3(0, 0.14, 0.08)
	scope.rotation_degrees.x = 90
	add_child(scope)

func build_msr():
	# Modern competition sniper
	var receiver = create_box(Vector3(0.06, 0.06, 0.4), weapon_color)
	receiver.position = Vector3(0, 0, 0.12)
	add_child(receiver)
	
	# Long float barrel
	var barrel = create_cylinder(0.012, 0.9)
	barrel.position = Vector3(0, 0, 0.55)
	barrel.rotation_degrees.x = 90
	add_child(barrel)
	
	# Adjustable stock
	var stock = create_box(Vector3(0.05, 0.08, 0.5), Color(0.15, 0.15, 0.15))
	stock.position = Vector3(0, 0, -0.18)
	add_child(stock)
	
	# Picatinny rail
	var rail = create_box(Vector3(0.04, 0.01, 0.35), Color(0.2, 0.2, 0.2))
	rail.position = Vector3(0, 0.04, 0.1)
	add_child(rail)
	
	# Long range scope
	var mount = create_box(Vector3(0.03, 0.03, 0.25), Color(0.1, 0.1, 0.1))
	mount.position = Vector3(0, 0.1, 0.12)
	add_child(mount)
	
	var scope = create_cylinder(0.022, 0.35)
	scope.position = Vector3(0, 0.14, 0.12)
	scope.rotation_degrees.x = 90
	add_child(scope)
	
	# Rear bag hook
	var hook = create_box(Vector3(0.02, 0.02, 0.1), Color(0.1, 0.1, 0.1))
	hook.position = Vector3(0, 0.02, -0.35)
	add_child(hook)

# Helper functions
func create_box(size: Vector3, color: Color) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh_inst.mesh = box
	mesh_inst.material_override = create_material(color)
	return mesh_inst

func create_cylinder(radius: float, height: float) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	mesh_inst.mesh = cyl
	mesh_inst.material_override = create_material(Color(0.15, 0.15, 0.15))
	return mesh_inst

func create_material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.8
	mat.roughness = 0.3
	return mat