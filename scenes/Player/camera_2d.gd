extends Camera2D

@onready var player = get_tree().get_first_node_in_group("player")
@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 3.0 # How many pixels ahead to peek
var kick_offset := Vector2.ZERO

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	# 1. Start at the player's base position
	var target_pos = player.global_position
	
	# 2. Push the target ahead in the direction they are moving
	if player.get("move_vector") != null and player.move_vector != Vector2.ZERO:
		target_pos += player.move_vector * look_ahead_distance
		
	# 3. Smoothly interpolate to the look-ahead position
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Add the kick offset to the lerp target
	global_position = global_position.lerp(target_pos + kick_offset, follow_speed * delta)

	
	# Quickly decay the kick back to zero (higher multiplier = stiffer spring)
	kick_offset = kick_offset.lerp(Vector2.ZERO, 20.0 * delta)

# various things
func zoom_to(target_zoom: Vector2, duration: float = 0.5) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", target_zoom, duration)

# Call this from player when need damage feedback from enemy touch
func apply_kick(direction: Vector2, strength: float = 6.0) -> void:
	# Kicks the camera opposite to the hit, or in the direction of the attack
	kick_offset += direction.normalized() * strength
