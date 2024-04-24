@tool

extends Sprite3D
@export var row: int = 1
@export var col: int = 1


func _ready():
	if row == 1:
		$LabelCol.text = str(col)
	else:
		$LabelCol.free()
		
	if col == 1:
		$LabelRow.text = str(row)
	else:
		$LabelRow.free()

func _on_collision_area_mouse_entered():
	SignalBus.square_entered.emit(self)
	#visible = false
