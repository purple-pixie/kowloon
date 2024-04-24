extends RigidBody3D

@export_range(1, 6) var face: int:
	set(new_face):
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
	#transform.basis = 
		var angle = randi_range(0, 3) * PI/2
		rotate_y(angle)
		face = new_face
	


func _on_input_event(camera, event, position, normal, shape_idx):
	pass # Replace with function body.
