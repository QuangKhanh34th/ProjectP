# A hurtbox placed on characters tell the game that "this character 
# can be hurt in this square/circle/space 

extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0 
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

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
				1: # HitOnce: too complicated, so skip the implementation for now 
					pass
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


# If the DisableHitBoxTimer ran out (0.5s), re-enable the CollisionShape2D, so the hurtbox can be hit again
func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
