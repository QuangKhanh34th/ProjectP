class_name M36AssaultRifle
extends WeaponBase

# --- Weapon Description ---
# single-target starter weapon, fire projectiles at the nearest enemy
# not affected by duration
# Max level evolution: choose between 2 modification
# Upgrade 1 : + 2 ammo, x2 size, weapon projectile explode on impact, dealing AoE damage,
# Upgrade 2: + 30 ammo, weapon shoot projectile in an interesting pattern


@onready var ShimaBunTimer: Timer = get_node("CooldownTimer")
@onready var ShimaBunAttackTimer: Timer = get_node("CooldownTimer/AttackTimer")

# ShimaBun
var projectile = preload("res://scenes/weapons/M36-AR/m36_ar_projectile.tscn")

var ammo_left = 0
var track_side: int = 1 # Alternates between 1 (right rail) and -1 (left rail)
var shot_counter: int = 0 # Tracks shots to know when to spawn a railroad tie

func _ready() -> void:
	#print("[shima_bun.gd] script loaded")
	max_level = 7
	base_damage = 1.5
	base_speed = 300
	base_size = 2.0
	base_ammo = 1
	attack()


func level_up(new_level: int = 0):
	if new_level:
		level = new_level 
	else: level += 1
	
	# might need to change this to accept csv/spreadsheet for easier stat tweaking 
	match level:
		2:
			base_ammo += 1
		3:
			base_damage += 5
		4:
			penetration_hp += 1
			base_ammo += 2
		5:
			base_damage += 5
			base_size += 20/100
		6:
			base_cooldown -= 20/100
		7:
			# upgrade 2
			penetration_hp += 999
			base_speed += 300
			base_ammo += 31
			base_delay = 0.00015
			base_cooldown -= 0.2	
			
			var tween = create_tween()
			# Tween the "zoom" property to Vector2(0.5, 0.5) over 1.5 seconds
			tween.tween_property(player.camera, "zoom", Vector2(4.0, 4.0), 1.5)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

# start the weapon timer if the weapon level is above 0 (meaning having/acquired
# the weapon)
func attack():
	print("[shima_bun.gd] attack function called. Level: ", level)
	if level > 0:
		ShimaBunTimer.wait_time = get_weapon_cooldown()
		ShimaBunAttackTimer.wait_time = get_weapon_delay()
		if ShimaBunTimer.is_stopped():
			ShimaBunTimer.start()
			print("[shima_bun.gd] ShimaBunTimer started")

# spawn a single projectile at a specific offset
func _spawn_bullet(spawn_pos: Vector2, target_pos: Vector2, is_tie: bool = false) -> void:
	# create an instance of the projectile (not shoot yet)
	var shimaBun_attack = projectile.instantiate()
	
	# pass down necessary weapon stats to the instance
	shimaBun_attack.weapon = self
	shimaBun_attack.damage = get_weapon_damage()
	shimaBun_attack.speed = get_weapon_speed()
	shimaBun_attack.penetration_hp = get_weapon_penetration()
	shimaBun_attack.size = get_weapon_size()
	shimaBun_attack.position = spawn_pos
	shimaBun_attack.target = target_pos
	
	# Pass the tie status down to the projectile before it enters the scene tree!
	shimaBun_attack.is_tie = is_tie
	
	get_tree().current_scene.add_child(shimaBun_attack)

func _on_shima_bun_timer_timeout() -> void:
	print("[shima_bun.gd] Main cooldown finished. Reloading")
	ammo_left = get_weapon_ammo()
	ShimaBunAttackTimer.start()


func _on_shima_bun_attack_timer_timeout() -> void:
	var enemies = player.get_nearby_enemies()
	if enemies.is_empty():
		#print("[shima_bun.gd] No enemies detected in detection area")
		return

	var closest_enemy = _get_closest_enemy(enemies)
	if closest_enemy == null:
		print("[shima_bun.gd] Couldn't find a valid closest enemy.")
		return

	if ammo_left > 0:
		# --- TRAIN TRACK PATTERN LOGIC ---
		if level == 7: # Replace with upgrade check later
			# 1. Get direction to enemy and calculate the 90-degree perpendicular vector
			var dir = global_position.direction_to(closest_enemy.global_position)
			var perp = dir.orthogonal() 
			var track_width = 10.0 # Distance in pixels from the center line to each rail
			
			shot_counter += 1
			
			# Every 4th shot, drop a railroad tie
			# Also verify if we have at least 3 ammo left to form a complete tie.
			if shot_counter % 4 == 0 and ammo_left >= 3:
				# Offsets for: Left Rail, Center Tie, and Right Rail
				var tie_offsets = [-track_width, 0.0, track_width]
				#var tie_offsets = [-track_width, -track_width * 0.5, 0.0, track_width * 0.5, track_width]
				
				for offset_val in tie_offsets:
					var offset_vec = perp * offset_val
					# Offset BOTH start and target so the tie travels in a straight, parallel line
					_spawn_bullet(global_position + offset_vec, closest_enemy.global_position + offset_vec, true)
					ammo_left -= 1
			else:
				# Standard alternating rails
				var offset_vec = perp * track_width * track_side
				_spawn_bullet(global_position + offset_vec, closest_enemy.global_position + offset_vec)
				track_side *= -1 # Flip to the other rail for the next shot
				ammo_left -= 1
		else:
			# Standard center-firing for lower weapon levels
			_spawn_bullet(global_position, closest_enemy.global_position)
			ammo_left -= 1
			#print("[shima_bun.gd] Projectile spawned. Remaining amount: ", ammo_left)
		if ammo_left > 0:
			ShimaBunAttackTimer.start()
		else:
			ShimaBunAttackTimer.stop()
			print("[shima_bun.gd] Attack ended. In Cooldown")
