# A hitbox placed on characters or entities tell the game that this weapon/bullet/hazard/thing 
# can hurt the player/enemy if its square/circle/space come into contact with the
# the player/ememy HURTBOX 

# in simpler words, "hitbox" touch "hurtbox" = "bullet" touch "body",
# "knife" slashed "body", "spikes" get stepped on by "body", etc...

extends Area2D

# damage number is just for instantiation purpose, this number is depended on
# which parent node the hitbox node is attached to. It can be 10 when attached to a specific
# enemy or 20 when attached to some projectile. The hurtbox will get this number 
# and emit the "hurt" signal
@export var damage = 1 

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer


# disable the hitbox and start the timer, effectively making the weapon/bullet/hazard/thing 
# cannot damage anyone hurtbox for the timer duration. Without this, AoE hazards on screen
# will absolutely demolish player/enemy in miliseconds because it deals damage too fast and
# too frequent (too OP)
func tempDisable():
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()


func _on_disable_hit_box_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
