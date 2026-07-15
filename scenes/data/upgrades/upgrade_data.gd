class_name UpgradeData
extends Resource

@export var id: String # e.g., "shimabun_1"
@export var display_name: String # e.g., "Shima Bun"
@export_multiline var description: String # _multiline makes the Inspector box bigger
@export var icon: Texture2D # Weapon sprite
@export var level: int = 1
@export var max_level: int = 5
@export var type: String = "weapon" # "weapon" or "passive_item"

# If it's a weapon, we can directly link the .tscn file
@export var weapon_scene: PackedScene 

# link ANOTHER UpgradeData resource as a prerequisite
@export var prerequisite: UpgradeData
