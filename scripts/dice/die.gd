class_name Die
extends RigidBody3D

var highlighted = false
var selected = false
var selectable = false
var selected_signal = SignalBus.die_selected

const SELECTABLE = 0
const SELECTED = 1
const HIGHLIGHTED = 2

var highlight_albedo = {
	SELECTABLE: Vector4(0.4, 0.45, 0.1, 0.8),
	SELECTED: Vector4(0, 0.9, 0, 1),
	HIGHLIGHTED: Vector4(0.8, 0.9, 0.2, 1),
}

@export_range(1, 6) var face

func set_outline_state(state: int, _visible = true):
	$Cube/outline.set_instance_shader_parameter("albedo", highlight_albedo[state])
	$Cube/outline.visible = _visible

func swap_to_face(new_face: int):
	transform.basis = Basis(Vector3.RIGHT, 0)
	match new_face:
		1: 
			rotate_x(-PI/2)
		2: 
			rotate_z(PI/2)
		3: 
			pass
		4:
			rotate_z(PI)
		5:
			rotate_z(-PI/2)
		6:
			rotate_x(PI/2)
	var angle = randi_range(0, 3) * PI/2
	rotate_y(angle)
	face = new_face	


func _on_mouse_entered():
	if selectable and not selected:
		set_outline_state(HIGHLIGHTED, true)


func _on_mouse_exited():
	if selectable and not selected:
		set_outline_state(SELECTABLE, true)


func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if selectable and not selected:
			select_die(true)
		elif selected:
			select_die(false)


func select_die(is_now_selected=true):
	if selected == is_now_selected:
		return
	selected = is_now_selected
	set_outline_state(SELECTED, is_now_selected)
	if selectable and not selected:
		set_outline_state(SELECTABLE, true)
	selected_signal.emit(self)
	
