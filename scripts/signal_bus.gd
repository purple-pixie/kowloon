extends Node

# emitted when a die finishes rolling
signal roll_finished()

# emitted when the selectable die faces changes - now-selectable faces provided
signal faces_made_selectable(faces)

# emitted when a [rolling] die is selected/unselected
signal die_selected(selected: Die)

# emitted when a placing_die is selected/unselected
signal die_placing_selected(selected: Die)

# emitted when a sqaure of the board is mouse_entered
signal square_entered(square)

# emitted when a hand of rolled dice is kept
signal hand_kept()

# emitted when a die is placed on the board
signal die_placed()
