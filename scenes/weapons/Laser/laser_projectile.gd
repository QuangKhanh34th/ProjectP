extends AOEProjectile


@export var fade_time: float = 0.3 # How many seconds the fade-out takes
var target = Vector2.ZERO



func _ready() -> void:
	super()
	# damage_type passed from weapon
	damage_type = self.damage_type
	
	# Lifecycle
	# 1. Instantly point toward the target
	var angle_dir = global_position.direction_to(target)
	rotation = angle_dir.angle() 
	
	# 2. Scale beam thickness (Y-axis) by the size stat
	scale.y = size 

	
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
