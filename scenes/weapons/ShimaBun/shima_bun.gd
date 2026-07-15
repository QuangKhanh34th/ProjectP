extends WeaponBase

@onready var ShimaBunTimer: Timer = get_node("ShimaBunTimer")
@onready var ShimaBunAttackTimer: Timer = get_node("ShimaBunTimer/ShimaBunAttackTimer")

# ShimaBun
var projectile = preload("res://scenes/weapons/ShimaBun/shima_bun_projectile.tscn")

var ammo_left = 0


func _ready() -> void:
	print("[shima_bun.gd] script loaded")
	attack()


func level_up():
	level += 1
	
	# might need to change this to accept csv/spreadsheet for easier stat tweaking 
	match level:
		2:
			base_ammo = 2
			base_cooldown = 0.75
		3:
			base_damage = 20

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
		# create an instance of the projectile (not shoot yet)
		var shimaBun_attack = projectile.instantiate()

		# pass down necessary weapon stats to the instance
		shimaBun_attack.damage = get_weapon_damage()
		shimaBun_attack.speed = get_weapon_speed()
		shimaBun_attack.penetration_hp = get_weapon_penetration()
		shimaBun_attack.size = get_weapon_size()

		# give the instance an idea where to fly at
		shimaBun_attack.position = global_position
		shimaBun_attack.target = closest_enemy.global_position

		# spawn the projectile (BOOM BOOM)
		get_tree().current_scene.add_child(shimaBun_attack)
		

		# do all the of above over again until burst end
		ammo_left -= 1
		#print("[shima_bun.gd] Projectile spawned. Remaining amount: ", ammo_left)
		if ammo_left > 0:
			ShimaBunAttackTimer.start()
		else:
			ShimaBunAttackTimer.stop()
			print("[shima_bun.gd] Attack ended. In Cooldown")
