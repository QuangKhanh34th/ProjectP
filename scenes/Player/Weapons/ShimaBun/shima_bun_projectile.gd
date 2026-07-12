extends Area2D

# --- Stat initialization ---
# don't need to look at the number in this script as they are passed down from
# the weapon's script "shima_bun.gd"
var damage = 10
var speed = 100
var penetration_hp = 1 
var size = 1.0
# var knockback_amount = 100

# variables describing which direction to shoot the projectile
var target = Vector2.ZERO
var angle = Vector2.ZERO

signal remove_from_array(object)

func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
			


# combine angle and speed to launch the projectile
func _physics_process(delta: float) -> void:
	position += angle*speed*delta


# currently treating each enemy passed as 1 charge, might need to change
# if we plan to add enemy that resist to penetration 
func enemy_hit(charge = 1):
	penetration_hp -= charge
	# putting emit_signal here mean making the projectile hit an enemy
	# multiple times as long as it still in contact with the enemy hurtbox
	# emit_signal("remove_from_array", self) 
	if penetration_hp <= 0:
		# clean up the already-removed projectile from hurtbox's hit_once_array
		# list so the list stay clean
		emit_signal("remove_from_array", self)
		queue_free() # hit enemy then disappear

# If the projectile missed the target, disappear after 10s
func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free() 
