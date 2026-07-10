# A hurtbox placed on characters tell the game that "this character 
# can be hurt in this square/circle/space 

extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0 
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

var hit_once_array = []

signal hurt(damage)

func _on_area_entered(area: Area2D) -> void:
	# Check if the Area2D object that touch the HurtBox is an Attack (the node is in group named "attack")
	# For later when we have other Area2D that is not an attack like exp orb, items
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			# match = switch-case
			match HurtBoxType:
				# Cooldown: 
				# Disables the HurtBox's collision temporarily and starts a timer. (set to 0.5s)
				# This makes the entity briefly invincible (i-frames) after getting hit.
				0: 
					collision.call_deferred("set","disabled",true)
					disableTimer.start()
				1: # HitOnce: 
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						# check if the attack has the signal called "remove_from_array"
						# and remove the attack from the "hit_once_list" array.
						# Depend on how the attack is coded (how it handle emitting the "remove_from_array" signal)
						# that the attack can either be:
						# 1. Hit an enemy repeatedly as long as its hitbox still collide with the hurtbox
						# 2. Remove itself from "hit_once_list" array when disappeared so the array don't full of dead attack references
						if area.has_signal("remove_from_array"):
							# safety check, check if remove_from_array from hitbox 
							# is wired up to remove_from_list 
							if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								area.connect("remove_from_array", Callable(self, "remove_from_list"))
					else:
						# ignore that specific instance of the projectile,
						# return null, skipping broadcasting "hurt" signal
						return
								
				# DisableHitBox:
				# Instead of making itself invincible, it tells the attacker's HitBox 
				# to turn off temporarily via area.tempDisable(). This is useful for lingering 
				# area-of-effect (AoE) attacks; the AoE stays on screen, but it stops dealing damage for a few seconds.
				2: 
					if area.has_method("tempDisable"): # See hitbox.gd for more explanation on this method
						area.tempDisable()
			
			# Extract the "damage" value from the Area2D
			var damage = area.damage
			# broadcast the damage value to the custom signal "hurt" 
			# The node that have this HurtBox node attached to it, connected to the "hurt" signal
			# will receive the damage value and do something with it (subtract hp with damage, check player-mobile.gd for ref)
			emit_signal("hurt", damage) 
			
			# an if statement specificly for enemy's hurtbox, letting the player's projectile know 
			# it successfully hit a target
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

# remove the attack instance from hit_once_array
func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)


# If the DisableHitBoxTimer ran out (0.5s), re-enable the CollisionShape2D, so the hurtbox can be hit again
func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
