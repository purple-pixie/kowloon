extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	look_at(Vector3.ZERO)


func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_move"):
		position = position.rotated(Vector3.UP, 0.003 * -event.relative[0])
		position = position.rotated(global_transform.basis.x, 0.003 * -event.relative[1])
		look_at((Vector3.ZERO))
	elif event.is_action_pressed("zoom_in"):
		fov = max(fov-5, 30)
	elif event.is_action_pressed("zoom_out"):
		fov = min(fov+5, 80)
