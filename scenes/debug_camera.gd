extends Camera2D

@onready var player = get_tree().get_first_node_in_group("player")
var follow_speed = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, follow_speed * delta)
