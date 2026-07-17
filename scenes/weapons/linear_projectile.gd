class_name LinearProjectile 
extends Hitbox

# passed down by the weapon's script when it initialize the projectile
# damage is inherited when extending Hitbox
var speed: float
var penetration_hp: int
var size: float
var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

# Linear projectile generally hit once per enemy
signal remove_from_array

func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	# we can put emit_signal here to make the projectile hit an enemy
	# multiple times as long as it still in contact with the enemy hurtbox.
	# Useful for projectiles that spin around player AND have limited
	# contact count (maybe useless actually?)
	# emit_signal("remove_from_array", self) 
	penetration_hp -= charge
	if penetration_hp <= 0:
		# clean up the already-removed projectile from hurtbox's hit_once_array
		# list so the list stay clean
		remove_from_array.emit(self)
		queue_free() # hit the last enemy then disappear
