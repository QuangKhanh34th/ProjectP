class_name MeleeProjectile 
extends Hitbox

# Required by hurtbox.gd (Case 1: HitOnce) to clean up enemy memory arrays
signal remove_from_array(object)

var damage_type: int = 1
var size: float

func _ready() -> void:
	# scale sweep size with size
	# this affect the node this script attached to its scale
	# meaning both sprite and collision shape should follow
	scale = Vector2(size, size)

# Override enemy_hit from Hitbox
func enemy_hit(_charge: int = 1) -> void:
	# Disable collision so it can't hit any more enemies, but let 
	# the visual animation finish
	$CollisionShape2D.set_deferred("disabled", true)

# Call this when the AnimatedSprite2D finishes its swing animation
func cleanup_attack() -> void:
	remove_from_array.emit(self)
	queue_free()
