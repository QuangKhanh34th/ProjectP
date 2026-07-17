extends LinearProjectile

# stats are inheritted by LinearProjectile and 
# modified by the weapon 
@onready var static_sprite: Sprite2D = %Sprite2D
@onready var impact_sprite: AnimatedSprite2D = %ImpactSprite
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Run LinearProjectile's _ready() to calculate direction and base rotation
	super()

# Override LinearProjectile's enemy_hit to handle visual impact animations
func enemy_hit(charge: int = 1) -> void:
	penetration_hp -= charge
	
	# If we still have pierce remaining (e.g., from level upgrades), keep flying![cite: 1]
	if penetration_hp > 0:
		return
		
	# 1. Stop the projectile from moving further[cite: 1]
	speed = 0
	
	# 2. Disable collision immediately so it can't damage other enemies while exploding[cite: 1]
	collision.set_deferred("disabled", true)
	
	# 3. Clean up the attack reference from the enemy's hurtbox memory array[cite: 1]
	remove_from_array.emit(self)
	
	# 4. Swap the visuals from the static bullet to the impact spritesheet
	if static_sprite:
		static_sprite.hide()
	if impact_sprite:
		impact_sprite.show()
		impact_sprite.play("impact")
		
		# 5. Wait for the explosion animation to finish before destroying the node
		await impact_sprite.animation_finished
		
	queue_free()

# If the projectile missed the target, disappear after 10s
func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

# If the projectile leaves the screen
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
