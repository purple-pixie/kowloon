class_name RollingController

extends Node3D

var roll_finished = true
@onready var dice = $Dice.get_children()
@onready var rules = $RulesLogic
@onready var labels = $Floor/Labels
#var faces = []
#var selected_faces = []
@onready var buttons = {
	&"roll": $Buttons/RollButton,
	&"undo": $Buttons/RightSide/UndoButton,
	&"keep_hand": $Buttons/RightSide/KeepHandButton,
	&"keep_meld": $Buttons/RightSide/KeepMeldButton,
}


func _ready():
	SignalBus.connect("roll_finished", _on_die_roll_finished)
	SignalBus.connect("die_selected", _on_die_selected)
	
	
func reset():
	for die in dice:
		die.reset()
	labels.visible = false	
	buttons[&"roll"].visible = true
	update_buttons()
	
	
func get_faces_kept():
	return get_available_faces(false, true)
	
	
func _on_die_selected(_die):
	signal_selectable_dice()	
	update_buttons()
	
	
func _input(event):
	if not roll_finished:
			return
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
		for die in dice:
			die.select_die(false)
		signal_selectable_dice()
		
		
func _on_die_roll_finished():
	roll_finished = true
	for die in dice:
		if die.is_rolling:
			roll_finished = false
	if not roll_finished:
		return
		
	for die in dice:
		die.global_position = die.tidy_pos
	signal_selectable_dice()
	labels.visible = true
	
	
	
func get_available_faces(selected=null, kept=null):
		## get the faces on the rolled dice
		## if selected is not null, the die's selected value must match
		## similarly for kept
		var faces = []
		for die in dice:
			if (
					((selected == null) or (selected == die.selected)) 
					and ( (kept == null) or kept == die.kept)
			):
				faces.append(die.face)
		return faces
	
	
func signal_selectable_dice():
	var available = get_available_faces(null, false)
	var selected = get_available_faces(true, false)
	SignalBus.faces_made_selectable.emit(
			rules.get_selectable_dice(available, selected)
	)


func _on_roll_button_pressed():
	if not roll_finished:
		return
	
	#dice = $Dice.get_children()
	for die in dice:
		die.reset()
		die.roll()
		
	roll_finished = false
	labels.visible = false
	buttons[&"roll"].visible = false
	#$Buttons/RollButton.visible = false
	
func _on_keep_meld_button_pressed():
	# TODO
	# keep hand I guess
	var meld = get_available_faces(true, false)
	if not rules.is_legal_meld(meld):
		return
	for die in dice:
		if die.selected:
			die.keep()
	signal_selectable_dice()
	update_buttons()

func update_buttons():
	var available = []
	var selected = []
	var kept = []
	for die in dice:
		if die.selected:
			available.append(die.face)
			selected.append(die.face)
		elif die.kept:
			kept.append(die.face)
		else:
			available.append(die.face)
			
	buttons[&"undo"].disabled = len(selected) == 0 and len(kept) == 0
	buttons[&"keep_hand"].disabled = len(rules.find_biggest_hand(available)) > 0
	buttons[&"keep_meld"].disabled = not rules.is_legal_meld(selected)	


func _on_keep_hand_button_pressed():
	var remaining = get_available_faces(false, false)
	if len(rules.get_selectable_dice(remaining, [])):
		return
	else:
		SignalBus.hand_kept.emit()


func _on_undo_button_pressed():
	for die in dice:
		die.selected = false
		die.selectable = false
		if die.kept:
			die.keep()
	signal_selectable_dice()
	buttons[&"keep_meld"].disabled = true
	buttons[&"keep_hand"].disabled = true
	buttons[&"undo"].disabled = true
