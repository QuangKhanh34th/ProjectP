extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")

func add_weapon(weapon_scene: PackedScene):
	var weapon_instance = weapon_scene.instantiate()
	weapon_instance.set("player", player)
	add_child(weapon_instance)
