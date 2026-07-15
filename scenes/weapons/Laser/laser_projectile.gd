extends Area2D

var damage = 10
var size = 1.0
var duration = 1.0
@export var fade_time: float = 0.3 # How many seconds the fade-out takes
var target = Vector2.ZERO
var damage_type = 0

signal remove_from_array(object)

func _ready() -> void:
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

# --- INFINITE PIERCE OVERRIDE ---
# When an enemy hurtbox touches the laser and calls enemy_hit():
func enemy_hit(_charge = 1) -> void:
	# Intentionally do NOTHING here!
	# By not reducing penetration_hp and not calling queue_free(), 
	# the laser will pierce 100% of enemies it touches.
	pass

# Clean up after the visual flash finishes
func _on_duration_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
