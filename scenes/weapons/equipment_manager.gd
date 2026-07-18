class_name EquipmentManager
extends Node2D

@onready var player: Player = get_parent() as Player

func add_weapon(weapon_scene: PackedScene):
	var weapon_instance := weapon_scene.instantiate() as WeaponBase
	if weapon_instance == null:
		push_error("Weapon scene must extend WeaponBase.")
		return
	weapon_instance.set_player(player)
	add_child(weapon_instance)

func apply_upgrade(upgrade: UpgradeData) -> void:
	# 1. Check if the upgrade actually contains a weapon scene
	if upgrade.weapon_scene == null:
		push_error("UpgradeData is missing a weapon_scene PackedScene")
		return

	# 2. Loop through all currently equipped weapons
	for weapon in get_children():
		if weapon is WeaponBase:
			# Compare the file path of the equipped weapon with the upgrade's scene file path
			if weapon.scene_file_path == upgrade.weapon_scene.resource_path:
				print("[WeaponManager] Upgrading existing weapon: ", weapon.name)
				weapon.level_up(upgrade.level)
				return
	
	# 3. If the loop finishes without returning, we don't own this weapon yet
	print("[WeaponManager] Adding brand new weapon: ", upgrade.display_name)
	add_weapon(upgrade.weapon_scene)
