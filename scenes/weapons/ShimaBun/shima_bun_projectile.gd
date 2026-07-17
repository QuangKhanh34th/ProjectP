extends LinearProjectile

# stats are inheritted by LinearProjectile and 
# modified by the weapon 

func _ready() -> void:
	# Run LinearProjectile's _ready() to calculate direction and base rotation
	super()


# If the projectile missed the target, disappear after 10s
func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

# If the projectile leaves the screen
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
