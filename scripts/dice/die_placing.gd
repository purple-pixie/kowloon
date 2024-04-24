extends Die


# Called when the node enters the scene tree for the first time.
func _ready():
	selectable = true
	selected_signal = SignalBus.die_placing_selected
	set_outline_state(SELECTABLE, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
