
class_name AOEProjectile
extends Hitbox

@onready var disableHitBoxTimer: Timer = $DisableHitBoxTimer
@onready var collision: CollisionShape2D = $CollisionShape2D

var damage_type: int
const BASE_HITBOX_DELAY: float = 0.5 # second
var hitbox_delay: float
var size: float
var duration: float



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not hitbox_delay:
		disableHitBoxTimer.wait_time = BASE_HITBOX_DELAY
	disableHitBoxTimer.timeout.connect(_on_disable_hit_box_timer_timeout)



# When an enemy hurtbox touches the laser and calls enemy_hit():
func enemy_hit(_charge = 1) -> void:
	# Intentionally do NOTHING here!
	# AoE projectiles/fields don't have penetration (or are them?).
	pass
	
# disable the hitbox and start the timer, effectively making the weapon/bullet/hazard/thing 
# cannot damage anyone hurtbox for the timer duration. Without this, AoE hazards on screen
# will absolutely demolish player/enemy in miliseconds because it deals damage too fast and
# too frequent (too OP)
func tempDisable():
	collision.call_deferred("set", "disabled", true)
	disableHitBoxTimer.start()


func _on_disable_hit_box_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
