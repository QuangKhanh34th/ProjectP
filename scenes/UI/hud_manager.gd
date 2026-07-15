extends Control

@onready var exp_bar = %ExpBar
@onready var lvl_up_screen = $LevelUpContainer

func reset_joystick():
	#Input.action_release("ui_left")
	#Input.action_release("ui_right")
	#Input.action_release("ui_up")
	#Input.action_release("ui_down")
	#move_vector = Vector2.ZERO
	
	# 2. Reset the virtual joystick visually and internally so the thumbstick snaps back to center
	var joystick = get_tree().current_scene.get_node_or_null("CanvasLayer/HUDManager/Virtual Joystick")
	if joystick and joystick.has_method("_reset"):
		joystick._reset()
		joystick.hide()

# TODO: Add player actual death
func _on_player_health_updated(current_hp: int, max_hp: int) -> void:
	pass # Replace with function body.


func _on_player_xp_updated(current_exp: int, max_exp: int) -> void:
	exp_bar.set_exp_bar(current_exp, max_exp)


func _on_player_leveled_up(new_level: int) -> void:
	exp_bar.set_level_label(new_level)
	reset_joystick()
	lvl_up_screen.show_level_up_menu(new_level)


func _on_player_level_up_choice_selected() -> void:
	lvl_up_screen.hide_level_up_menu()
