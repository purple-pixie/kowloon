extends Node3D

@onready var board = $Board
@onready var rolling = $Rolling


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.hand_kept.connect(on_hand_kept)
	remove_child(board)


func on_hand_kept():
	var faces = rolling.get_faces_kept()
	remove_child(rolling)
	add_child(board)
	board.ready_hand(faces)
	#var timer := Timer.new()
	#add_child(timer)
	#timer.wait_time = 5.0
	#timer.one_shot = true
	#timer.timeout.connect(_on_die_placed)
	#timer.start()
	

func _on_dice_placed():
	remove_child(board)
	add_child(rolling)
	rolling.reset()
	

