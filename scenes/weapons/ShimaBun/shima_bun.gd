extends Node2D

@onready var ShimaBunTimer = get_node("ShimaBunTimer")
@onready var ShimaBunAttackTimer = get_node("ShimaBunTimer/ShimaBunAttackTimer")

# ShimaBun
var player: Player
var projectile = preload("res://scenes/weapons/ShimaBun/shima_bun_projectile.tscn")

# --- Weapon stats ---
var level = 1
var base_damage = 5
var base_speed = 100
var penetration_hp = 1
var base_size = 1.0 # how large is the projectile
# var base_knockback = 100
var base_ammo = 20 # how many bullet fired in one burst
var base_cooldown = 0.5 # how long to wait between each burst (in seconds)
var base_delay = 0.05 # how long to wait between each bullet in one burst (in seconds)
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
		ShimaBunTimer.wait_time = base_cooldown
		ShimaBunAttackTimer.wait_time = base_delay
		if ShimaBunTimer.is_stopped():
			ShimaBunTimer.start()
			print("[shima_bun.gd] ShimaBunTimer started")

func _on_shima_bun_timer_timeout() -> void:
	print("[shima_bun.gd] Main cooldown finished. Reloading")
	ammo_left = base_ammo
	ShimaBunAttackTimer.start()


func _on_shima_bun_attack_timer_timeout() -> void:
	var enemies = player.get_nearby_enemies()
	if enemies.is_empty():
		print("[shima_bun.gd] No enemies detected in detection area")
		return

	var closest_enemy = _get_closest_enemy(enemies)
	if closest_enemy == null:
		print("[shima_bun.gd] Couldn't find a valid closest enemy.")
		return

	if ammo_left > 0:
		# create an instance of the projectile (not shoot yet)
		var shimaBun_attack = projectile.instantiate()

		# pass down necessary weapon stats to the instance
		shimaBun_attack.damage = base_damage
		shimaBun_attack.speed = base_speed
		shimaBun_attack.penetration_hp = penetration_hp
		shimaBun_attack.size = base_size

		# give the instance an idea where to fly at
		shimaBun_attack.position = global_position
		shimaBun_attack.target = closest_enemy.global_position

		# spawn the projectile (BOOM BOOM)
		self.add_child(shimaBun_attack)
		

		# do all the of above over again until burst end
		ammo_left -= 1
		print("[shima_bun.gd] Projectile spawned. Remaining amount: ", ammo_left)
		if ammo_left > 0:
			ShimaBunAttackTimer.start()
		else:
			ShimaBunAttackTimer.stop()
			print("[shima_bun.gd] Attack ended. In Cooldown")


func _get_closest_enemy(enemies: Array[Node2D]):
	var closest_enemy = null
	var shortest_distance = INF

	for enemy in enemies:
		# failsafe in case an enemy died but hasn't left the array yet
		if not is_instance_valid(enemy):
			continue

		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < shortest_distance:
			shortest_distance = dist
			closest_enemy = enemy

	if closest_enemy == null:
		return
		
	return closest_enemy
