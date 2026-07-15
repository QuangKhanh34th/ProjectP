extends WeaponBase

# --- Weapon Description ---
# deal damage every 0.5s when enemy inside laser beam
# damage affected by size
# not affected by ammo, speed, penetration


@onready var cooldown_timer: Timer = $CooldownTimer
var laser_beam_scene = preload("res://scenes/weapons/Laser/laser_projectile.tscn")


func _ready() -> void:
	# --- CUSTOM STAT OVERRIDES ---
	base_damage = 2.0
	base_size = 1.0
	base_cooldown = 5.0
	base_duration = 2.5
	
	attack()

func level_up():
	level += 1
	
	# might need to change this to accept csv/spreadsheet for easier stat tweaking 
	match level:
		2:
			base_duration = 3.5
		3:
			base_size += 0.5
		4:
			base_cooldown -= 2.0
		5:
			base_size += 0.5
			base_damage += 10

func attack() -> void:
	if level > 0:
		
		if cooldown_timer.is_stopped():
			cooldown_timer.start()
		cooldown_timer.wait_time = get_weapon_cooldown()



# Override damage to scale with BOTH Power and Size!
func get_weapon_damage() -> int:
	var weapon_damage := base_damage
	if has_player():
		weapon_damage *= _percent_multiplier(player.power)
		weapon_damage *= _percent_multiplier(player.size) # Size boosts damage!
	return max(1, roundi(weapon_damage))

# Ignore get_weapon_speed(), get_weapon_penetration(), and get_weapon_ammo() 
# by never calling them when spawning the attack

# --- FIRING LOGIC ---

func _on_cooldown_timer_timeout() -> void:
	var enemies = player.get_nearby_enemies()
	if enemies.is_empty():
		cooldown_timer.start(0.1)
		return

	var closest_enemy = _get_closest_enemy(enemies)
	if closest_enemy == null:
		cooldown_timer.start(0.1)
		return

	# Instantiate the laser beam
	var laser = laser_beam_scene.instantiate()
	
	# Only pass the stats the laser actually cares about
	laser.damage_type = self.damage_type
	laser.damage = get_weapon_damage()
	laser.size = get_weapon_size() # Used to make the beam visually thicker
	laser.duration = get_weapon_duration()
	laser.target = closest_enemy.global_position

	add_child(laser)
	laser.position = Vector2.ZERO
	
	laser.tree_exited.connect(_on_laser_finished)

# Restart cooldown for the next blast when laser duration end
func _on_laser_finished() -> void:
	cooldown_timer.wait_time = get_weapon_cooldown()
	cooldown_timer.start()
