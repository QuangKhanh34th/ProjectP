extends ColorRect


var mouse_over: bool = false
var item = null

# Signal emitted when the player clicks this upgrade card
signal upgrade_selected(weapon_to_upgrade)


@onready var item_icon: TextureRect = %ItemIcon
@onready var name_label: Label = %ItemNameLabel
@onready var desc_label: Label = %ItemDescLabel
@onready var level_label: Label = %ItemLevelLabel

var target_weapon: Node2D = null



func _on_mouse_entered() -> void:
	print("mouse entered")
	mouse_over = true


func _on_mouse_exited() -> void:
	print("mouse exited")
	mouse_over = false


func _on_button_pressed() -> void:
	print("signal emitted")
	emit_signal("upgrade_selected", item)
