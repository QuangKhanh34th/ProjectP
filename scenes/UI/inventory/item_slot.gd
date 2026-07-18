class_name ItemSlot
extends ColorRect

var is_empty: bool = true
@onready var icon: TextureRect = %Icon
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
	clear_slot()

func clear_slot() -> void:
	print("clear_slot called")
	is_empty = true
	icon.texture = null
	level_label.text = ""
	modulate.a = 0.4 # Dim empty boxes slightly!

func set_slot(data: UpgradeData) -> void:
	is_empty = false
	modulate.a = 1.0 # Fully brighten when filled
	if data.icon:
		icon.texture = data.icon
	level_label.text = str(data.level)

func update_slot(data: UpgradeData) -> void:
	# Called when leveling up an item we already own
	level_label.text = str(data.level)
