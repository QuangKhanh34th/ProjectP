class_name WeaponManager
extends Node2D

@onready var player: Player = get_parent() as Player

func add_weapon(weapon_scene: PackedScene):
	var weapon_instance := weapon_scene.instantiate() as WeaponBase
	if weapon_instance == null:
		push_error("Weapon scene must extend WeaponBase.")
		return
	weapon_instance.set_player(player)
	add_child(weapon_instance)
