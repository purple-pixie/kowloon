@tool
extends Node

@export var add = false
@export var remove = false

# Called when the script is executed (using File -> Run in Script Editor).
func _process(delta):
	if remove:
		remove = false
		for square in get_children():
			for child in square.get_children():
				if child is Label3D:
					continue
				child.queue_free()
		return
		
	if not add:
		return
	add = false
	for square in get_children():
		var new_area = Area3D.new()
		square.add_child(new_area)
		new_area.owner = get_tree().edited_scene_root
		new_area.collision_layer = 8
		new_area.collision_mask = 8
		var new_shape = CollisionShape3D.new()
		new_area.add_child(new_shape)
		new_shape.owner = get_tree().edited_scene_root
		new_shape.shape = preload("res://resources/box_shape_square.tres")
		new_shape.transform.translated_local(Vector3(0.034, 0, 0))
		square.do_connect(new_area.mouse_entered)
