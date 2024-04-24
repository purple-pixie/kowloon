class_name BuildingController
extends Node3D

signal row_completed(row)
signal column_completed(col)
signal diagonal_completed(direction)

const POSITIVE = 1
const NEGATIVE = -1
var die_building = preload("res://scenes/die_placing.tscn")

# _dice_cube layout:
# 3-d array
# inner cells are arrays of the dice in that cell
var _dice_cube = [null]
var _squares = [null]
var _hand_positions = []
var _hand = []
var _selected
@onready var _mouse_cast = $Camera3D/MouseCast
@onready var _ghost = $Ghost

func reset():
	for die in $Dice.get_children():
		$Dice.remove_child(die)
		die.queue_free()
	_dice_cube = [null]
	_squares = [null]
	_ready()

func _ready():
	for i in 6:
		_dice_cube.append([null, [], [] ,[], [], [], []])
	for i in range(1, 7):
		var row = [null]
		_squares.append(row)
		for j in range(1, 7):
			row.append(get_node("Squares/square_"+str(i)+"-"+str(j)))
	SignalBus.die_placing_selected.connect(_on_die_selected)
	SignalBus.square_entered.connect(_on_square_entered)
	
	for die in $Hand.get_children():
		_hand_positions.append(die.global_position)
		#die.queue_free()
		_hand.append(die)
		
	test()
		

func ready_hand(values):
	_hand = []
	for i in len(values):
		var new_die = die_building.instantiate()
		_hand.append(new_die)
		new_die.swap_to_face(values[i])
		$Hand.add_child(new_die)
		new_die.owner = get_tree().edited_scene_root
		new_die.global_position = _hand_positions[i]


func _input(event):
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
		_selected = null
		_ghost.visible = false
		for die in _hand:
			die.select_die(false)

		
func _on_die_selected(die):
	if die.selected:
		_selected = die
		for other_die in _hand:
			if other_die == die:
				continue
			if other_die.selected:
				other_die.select_die(false)
	

func _on_square_entered(square):
	if _selected:
		var row = square.row
		var col = square.col
		if not (row == _selected.face or col == _selected.face):
			return
		_ghost.position = square.position + Vector3(0, 2 * height_at(row, col) + 1.2, 0)
		_ghost.visible = true
		
func _process(_delta):
	if not _selected:
		_ghost.visible = false
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = $BoardCam
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * 100
	var cursorPos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
	if cursorPos:
		_selected.global_position = cursorPos
	
		
func test():	
	#for x in range(1, 7):
		#for y in range(1, 7):
			#add_die_at(x, y, y)
			
	for x in range(1, 7):
		for y in range(1, 7):
			if randi_range(0, 1):
				add_die_at(x, y, y)
		
func add_die_wherever(die):
	## add the die in some legal position
	var options = get_all_possible_places(die)
	var choice = randi_range(0, len(options)-1)
	var coords = options[choice]
	add_die_at(coords[0], coords[1], die)
	
func highest_complete_floor():
	var min_height = height_at(1, 1)
	for row in range(1, 7):
		for col in range(1., 7):
			var height = height_at(row, col)
			if height < min_height:
				min_height = height
	return min_height
	
func add_die_at(row, col, die):
	## add a die to the cube at row row and col col
	if die != col and die != row:
		print("illegal die face")
		return
	if not is_placeable_at(die, row, col):
		print("space isn't open")
		return
		
	_dice_cube[row][col].append(die)
	
	# create the physical die too
	var new_die = die_building.instantiate()
	$Dice.add_child(new_die)
	var y_offset = Vector3(0, height_at(row, col) * 2 - 1, 0)
	new_die.transform.origin = _squares[row][col].transform.origin + y_offset
	new_die.swap_to_face(die)
	#new_die.input_ray_pickable = false
	
	#TODO: work out dice not blocking placement / reporting as the square the belong to
	
	new_die.set_outline_state(0, false)
	
	
	# check for complete row
	var complete = true
	var height = height_at(row, 1)
	for i in range(2, 7):
		if height_at(row, i) != height:
			complete = false
			break
	if complete:
		row_completed.emit(row)
		
	# and column
	complete = true
	height = height_at(1, col)
	for i in range(2, 7):
		if height_at(i, col) != height:
			complete = false
			break
	if complete:
		column_completed.emit(col)	
		
	# check the diagonals
	if row == col:
		# positive
		complete = true
		height = height_at(1,1)
		for i in range(2, 7):
			if height_at(i, i) != height:
				complete = false
				break
		if complete:
			diagonal_completed.emit(POSITIVE)
		
		#and negative
		complete = true
		height = height_at(6,1)
		for i in range(2, 7):
			if height_at(7-i, i) != height:
				complete = false
				break
		if complete:
			diagonal_completed.emit(NEGATIVE)
		
		
func height_at(row, col):
	return len(_dice_cube[row][col])
		
func get_all_possible_places(die):
	## get all coordinates this die could be placed at
	var output = []
	var min_height = 999
	for i in range(1, 7):
		for coords in [[die, i], [i, die]]:
			# ugly kludge to avoid duplicating [die, die] 
			if i == die:
				if len(output) and output[-1][0] == die and output[-1][1] == die:
					output.pop_back()
			# split the coords out
			var row = coords[0]
			var col = coords[1]
			# if this is lower than our previous minimum then throw out all the values so far
			var height = height_at(row, col)
			if  height < min_height:
				output = []
				min_height = height
			# if this is at the minimum height then add to the list
			if height == min_height:
				output.append([row, col])
	return output
		
func is_placeable_at(die, row, col):
	## is this point available to place a die with face die in
	# get the current number of dice in this cell
	var height = height_at(row, col)
	# see if anything on the same row/col is at a lower height
	if height == 0:
		return true
	for i in range(1, 7):
		if height_at(die, i) < height:
			return false
	for j in range(1, 7):
		if height_at(j, die) < height:
			return false
	return true
	
