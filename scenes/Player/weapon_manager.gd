class_name WeaponManager
extends Node2D

@onready var player: Player = get_parent() as Player

func add_weapon(weapon_scene: PackedScene):
	var weapon_instance = weapon_scene.instantiate()
	weapon_instance.set("player", player)
	add_child(weapon_instance)
