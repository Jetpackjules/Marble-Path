extends RayCast3D

# Reference to the marker
@onready var marker = Global.cursor
#var push_pad = preload("res://Push_Pad.tscn")
var scenes = []  # List to store all the scenes
var current_scene_index = 0  # Index to keep track of the currently selected scene

var supplimental_rotation: float = 0
var current_rotation = 0

var preview_item = null

var preview_material = preload("res://Items/Preview.tres")
var default_material = preload("res://Items/Default_Material.tres")


func _ready():
	# Load all scenes from a certain folder
	
	var dir = DirAccess.open("res://Items/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			scenes.append(load("res://Items/" + file_name))
		file_name = dir.get_next()

func _input(event):
#	event is InputEventMouseButton and event.pressed
	if get_mouse_click_pos():
		# If left mouse button is clicked
		if event.is_action_pressed("left_click"):
			place_item()
		# If right mouse button is clicked, cycle to the next scene
		elif event.is_action_pressed("cycle_item"):
			cycle_scene(1)
		elif event.is_action_pressed("scroll_up"):
			supplimental_rotation += deg_to_rad(15)
			
		elif event.is_action_pressed("scroll_down"):
			supplimental_rotation -= deg_to_rad(15)
#	Needs to be one layer down to interact with placed items:
	elif event.is_action_pressed("mouse_middle_click"):
		remove_item()
		


func _physics_process(delta):
	var pos = get_mouse_click_pos(true)
	if pos:
		var cursor_pos = pos[0]
		Global.cursor.global_position = cursor_pos
		if preview_item:
			preview_item.visible = true
			preview_item.global_position = cursor_pos

			
			var reference_forward = Vector3.FORWARD
			var projected_forward = reference_forward - pos[1] * reference_forward.dot(pos[1])
			var target = cursor_pos + projected_forward.normalized()
			preview_item.look_at(target, pos[1])

			var interpolation_speed = 12
			current_rotation = lerp_angle(current_rotation, supplimental_rotation, interpolation_speed * delta)
			preview_item.rotate_object_local(Vector3.UP, current_rotation)
			
		else:
			preview_item = create_item(scenes[current_scene_index])
	elif preview_item:
		preview_item.visible = false

func get_mouse_click_pos(extra: bool = false, collider: bool = false):
	var space_state = get_world_3d().direct_space_state
	var camera = get_parent()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000

	var ray_array = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))
	
	if ray_array.has("position"):
		if collider:
			var test = ray_array["collider"].owner
			return ray_array["collider"].owner
			
		if ray_array["collider"].get_parent().get_name().find("tile") != -1:
			if extra:
				return [ray_array["position"], ray_array["normal"]]
			return ray_array["position"]
	
	return null

func place_item():
	var placed_item = preview_item
	preview_item = null
	change_mesh_material(placed_item, default_material, true)

func create_item(Item):
	var Item_Instance = Item.instantiate()
	var placing_pos: Array = get_mouse_click_pos(true)
	Item_Instance.global_position = placing_pos[0]
	
	var reference_forward = Vector3.FORWARD
	var projected_forward = reference_forward - placing_pos[1] * reference_forward.dot(placing_pos[1])
	var target = placing_pos[0] + projected_forward.normalized()
	Item_Instance.look_at(target, placing_pos[1])
	
	get_tree().get_root().add_child(Item_Instance)
	Item_Instance.look_at(target, placing_pos[1])
	change_mesh_material(Item_Instance, preview_material, false)
	return Item_Instance

func remove_item():
	var item = get_mouse_click_pos(false, true)
	if item.is_in_group("item"):
		item.queue_free()
	
func change_mesh_material(instanced_scene, material: StandardMaterial3D, collision: bool) -> void:
	if instanced_scene is MeshInstance3D:
		instanced_scene.material_override = material
	if instanced_scene is CollisionShape3D or instanced_scene is CollisionPolygon3D:
		instanced_scene.disabled = !collision
	for child in instanced_scene.get_children():
		change_mesh_material(child, material, collision)

func cycle_scene(direction):
	print("CYCLEING")
	current_scene_index += direction
	# Wrap around if we reach the beginning or end of the list
	current_scene_index = current_scene_index % scenes.size()
	preview_item.queue_free()
	preview_item = create_item(scenes[current_scene_index])
	
