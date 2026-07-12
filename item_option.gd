extends ColorRect

# Signal emitted when the player clicks this upgrade card
signal item_selected(weapon_instance: Node2D)

@onready var item_icon: TextureRect = %ItemIcon
@onready var name_label: Label = %ItemNameLabel
@onready var desc_label: Label = %ItemDescLabel
@onready var level_label: Label = %ItemLevelLabel

var target_weapon: Node2D = null

func _ready() -> void:
	# CRITICAL: Ensure this UI element processes input even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called by player.gd to populate the card's visual data
func set_item_data(weapon: Node2D, weapon_name: String, icon: Texture2D, description: String) -> void:
	target_weapon = weapon
	name_label.text = weapon_name
	desc_label.text = description
	level_label.text = "Level " + str(weapon.level + 1)
	if icon:
		item_icon.texture = icon

# Detect left mouse clicks or touch screen taps on the ColorRect
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		item_selected.emit(target_weapon)
