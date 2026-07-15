extends ColorRect


var mouse_over: bool = false
var chosen_upgrade: UpgradeData = null

# Store the custom resource data on this card
var item_data: UpgradeData = null

# Signal emitted when the player clicks this upgrade card
signal upgrade_selected(weapon_to_upgrade)


@onready var item_icon: TextureRect = %ItemIcon
@onready var name_label: Label = %ItemNameLabel
@onready var desc_label: Label = %ItemDescLabel
@onready var level_label: Label = %ItemLevelLabel

var target_weapon: Node2D = null


# Call this from your level_up_screen.gd when spawning the card!
func set_item(data: UpgradeData) -> void:
	chosen_upgrade = data
	%ItemIcon.texture = data.icon
	%ItemNameLabel.text = data.display_name
	%ItemDescLabel.text = data.description
	%ItemLevelLabel.text = "Lv. " + str(data.level)


func _on_button_pressed() -> void:
	print("[item_option.gd] signal emitted")
	emit_signal("upgrade_selected", chosen_upgrade)
