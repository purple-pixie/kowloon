extends Die

var start_pos
var tidy_pos
var roll_strength = 30
var is_rolling = false
var kept = false


@onready var raycasts = $RayCasts.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	tidy_pos = global_position
	start_pos = global_position + Vector3(6, 3, 2)
	face = randi_range(1, 6)
	#$"../..".roll_requested.connect(_roll_requested)
	SignalBus.faces_made_selectable.connect(_on_faces_made_selectable)
	#sleeping_state_changed.connect(_on_sleeping_state_changed)
	#shader.set_shader_param("strenth", randf_range(0.0, 1.0))
	
func reset():
	kept = false
	selected = false
	selectable = false
	$Cube/outline.visible = false
	global_position = start_pos
	face = randi_range(1, 6)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
func keep():
	kept = !kept
	selected = false
	selectable = false
	set_outline_state(0, false)
	global_position.x = -global_position.x
	
	
func _on_faces_made_selectable(faces):
	if selected or kept:
		return
	if face in faces:
		if selectable:
			return
		selectable = true
		set_outline_state(SELECTABLE, true)
	else:
		selectable = false
		set_outline_state(SELECTABLE, false)
		
	
func roll():
	# reset to base state
	reset()
	sleeping = false
	freeze = false
	# rotate randomly
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2*PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2*PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2*PI)) * transform.basis
	
	 # throw
	var throw_vector = Vector3(randf_range(-1,1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength /2
	apply_central_impulse(throw_vector * roll_strength)
	
	is_rolling = true


func _on_sleeping_state_changed():
	if sleeping:
		is_rolling = false
		selected = false
		selectable = false
		var landed_sanely = false
		for raycast:RayCast3D in raycasts:
			if raycast.is_colliding():
				landed_sanely = true
				freeze = true
				face = raycast.opposite_side
				SignalBus.roll_finished.emit()
		if not landed_sanely:
			print_debug("jacked")
			roll()


