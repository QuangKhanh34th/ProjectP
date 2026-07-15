extends SubViewport

func _ready() -> void:
	# Tell this viewport to render the exact same 2D world as the main game window
	world_2d = get_tree().root.world_2d
