# A hitbox placed on characters or entities tell the game that this weapon/bullet/hazard/thing 
# can hurt the player/enemy if its square/circle/space come into contact with the
# the player/ememy HURTBOX 

# in simpler words, "hitbox" touch "hurtbox" = "bullet" touch "body",
# "knife" slashed "body", "spikes" get stepped on by "body", etc...

# Currently, the base Hitbox is used for enemy collision damage
# and is inherited by base projectile types
class_name Hitbox
extends Area2D

@export var damage: float = 1

func enemy_hit(_charge: int = 1) -> void:
	pass # Override in subclasses if penetration or custom hit effects are needed
