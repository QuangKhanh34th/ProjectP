class_name WeaponBase
extends Node2D

var player: Player

# how weapon interact with enemy hurtbox (see hurtbox.gd)
# 0 = Cooldown
# 1 = HitOnce
# 2 = DisableHitBox
@export var damage_type = 0

@export var level: int = 1
@export var base_damage: float = 5.0
@export var base_speed: float = 100.0
@export var penetration_hp: int = 1
@export var base_size: float = 1.0
@export var base_ammo: int = 5
@export var base_cooldown: float = 0.5 # seconds
@export var base_delay: float = 0.05 # seconds
@export var base_duration: float = 1.0 # seconds


func set_player(value: Player) -> void:
	player = value


func has_player() -> bool:
	return is_instance_valid(player)

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
		
	#print("closest enemy: ", closest_enemy)
	return closest_enemy


func get_weapon_damage() -> int:
	var weapon_damage := base_damage
	if has_player():
		weapon_damage *= _percent_multiplier(player.power)
	return max(1, roundi(weapon_damage))


func get_weapon_speed() -> float:
	var weapon_speed := base_speed
	if has_player():
		weapon_speed *= _percent_multiplier(player.speed)
	return max(0.0, weapon_speed)


func get_weapon_penetration() -> int:
	var weapon_penetration := float(penetration_hp)
	if has_player():
		weapon_penetration *= _percent_multiplier(player.pierce)
	return max(1, roundi(weapon_penetration))


func get_weapon_size() -> float:
	var weapon_size := base_size
	if has_player():
		weapon_size *= _percent_multiplier(player.size)
	return max(0.0, weapon_size)


func get_weapon_ammo() -> int:
	var weapon_ammo := base_ammo
	if has_player():
		weapon_ammo += player.amount
	return max(1, weapon_ammo)


func get_weapon_cooldown() -> float:
	var weapon_cooldown := base_cooldown
	if has_player():
		weapon_cooldown *= _cooldown_multiplier(player.cooldown)
	return max(0.01, weapon_cooldown)


func get_weapon_delay() -> float:
	var weapon_delay := base_delay
	if has_player():
		weapon_delay *= _cooldown_multiplier(player.cooldown)
	return max(0.01, weapon_delay)

func get_weapon_duration() -> float:
	var weapon_duration := base_duration
	if has_player():
		weapon_duration *= _percent_multiplier(player.duration)
	return max(0.0, weapon_duration)

func _percent_multiplier(stat_bonus: float) -> float:
	return 1.0 + (stat_bonus / 100.0)


func _cooldown_multiplier(stat_bonus: float) -> float:
	return max(0.05, 1.0 - (stat_bonus / 100.0))
