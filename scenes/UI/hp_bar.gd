extends TextureProgressBar

var is_shaking: bool = false
var base_scale := Vector2.ONE
var time_elapsed: float = 0.0

func _ready() -> void:
	base_scale = scale
	# Set the pivot to the exact center of the bar so it vibrates in place
	pivot_offset = size / 2.0

func set_hp_bar(current_hp: int, max_hp: int):
	self.max_value = max_hp
	self.value = current_hp
	
	# Calculate HP percentage
	var hp_percent := float(current_hp) / float(max_hp)
	
	# Continuously shake if HP is at or below 25% (and player is still alive)
	is_shaking = (hp_percent <= 0.25 and current_hp > 0)
	
	# If died, snap back to normal
	if not is_shaking:
		rotation = 0.0
		scale = base_scale

func _process(delta: float) -> void:
	if not is_shaking:
		return
		
	time_elapsed += delta * 40.0

	
	# 2. Continuous heartbeat pulsing scale around base_scale
	var pulse := sin(time_elapsed) * 0.03
	scale = base_scale + Vector2(pulse, pulse)
