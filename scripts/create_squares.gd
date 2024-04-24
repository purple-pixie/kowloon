@tool
extends Node

@export var add = false
@export var remove = false
var square_prefab = preload("res://board_square.tscn")

# Called when the script is executed (using File -> Run in Script Editor).
func _process(delta):
	if remove:
		remove = false
		var squares = get_children()
		for square in squares:
			square.queue_free()
		return
	
	if not add:
		return
	add = false
	for row in range(1, 7):
		for col in range(1, 7):
			var square = square_prefab.instantiate()
			square.row = row
			square.col = col
			square.set_name("square_" + str(row) + "-" +  str(col))
			add_child(square)
			square.owner = get_tree().edited_scene_root
			square.transform.origin = Vector3(-8.4 + 2.4 * col, 1.01, -8.4 + 2.4 * row)
