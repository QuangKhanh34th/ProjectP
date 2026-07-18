extends AOEProjectile

@onready var startup_sprite = $SpriteContainer/StartupSprite
@onready var active_sprite = $SpriteContainer/ActiveSprite

@export var fade_time: float = 0.3 # How many seconds the fade-out takes
var target = Vector2.ZERO



func _ready() -> void:
	super()
	# damage_type passed from weapon
	damage_type = self.damage_type
	
	# Temporarily disable the hitbox and hide the active beam during startup
	collision.call_deferred("set", "disabled", true)
	active_sprite.hide()
	
	# Instantly point toward the target
	var angle_dir = global_position.direction_to(target)
	rotation = angle_dir.angle() 
	
	
	var player_clearance: float = 25.0  # Base distance from player center
	var head_radius: float = 6.0 * size # Dynamic radius based on your 12x12 sprite[cite: 1]
	position += angle_dir * (player_clearance + head_radius)
	
	# --- 2. COMPONENT-LEVEL SCALING ---
	# Scale the Startup Head uniformly (both X and Y) so the ball stays perfectly round!
	startup_sprite.scale = Vector2(size, size)

	# Scale the Active Beam ONLY in thickness (Y), leaving its X length intact!
	active_sprite.scale.y = size

	# Scale the Hitbox thickness (Y) to match the beam (preserving its base 0.3 X scale in your .tscn)[cite: 1]
	collision.scale.y = 0.3 * size
	 
	
	# Tell the shader to tile the texture vertically instead of stretching
	if active_sprite.material:
		active_sprite.material.set_shader_parameter("tiling_factor", Vector2(1.0, size))
	
	# Play startup animation and wait for the signal to finish
	startup_sprite.show()
	startup_sprite.play()
	await startup_sprite.animation_finished
	
	# Activate the beam visuals and enable damage collision
	active_sprite.show()
	active_sprite.play("active")
	collision.call_deferred("set", "disabled", false)
	
	# 3. Start duration timer, laser stay on until timer end
	$DurationTimer.wait_time = duration
	print("Laser Duration Timer: ", $DurationTimer.wait_time)
	print("laser damage: ", damage)
	print("laser size: ", size)
	$DurationTimer.start()
	
	# fadeout animation
	# 1. Protect against bugs if duration is somehow shorter than fade_time
	var actual_fade_time := minf(fade_time, duration)
	var active_time: float = duration - actual_fade_time
	
	# 2. Create the Godot 4 sequence timeline
	var tween := create_tween()
	
	# Step A: Wait at full opacity while the laser burns enemies
	tween.tween_interval(active_time)
	
	# Step B: Fade the root node's alpha (modulate:a) down to 0.0
	tween.tween_property(self, "modulate:a", 0.0, actual_fade_time)
	
	# Step C: Delete the laser from the game once the fade completes
	tween.tween_callback(queue_free)

# NO _physics_process() here. The laser does not travel over time.
