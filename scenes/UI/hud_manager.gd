extends Control

@onready var exp_bar = %ExpBar
@onready var lvl_up_screen = $LevelUpContainer
@onready var hp_bar = %HPBar
@onready var timer_label = %Timer
@onready var kill_label = %Kill

func _ready() -> void:
	# Connect to the global Stage Manager broadcasts
	SignalBus.stage_time_updated.connect(_on_stage_time_updated)
	SignalBus.kill_count_updated.connect(_on_kill_count_updated)
	
	# Initialize labels on startup
	_on_stage_time_updated(300)
	_on_kill_count_updated(0)

func _on_stage_time_updated(seconds: int) -> void:
	var minutes := seconds / 60
	var rem_seconds := seconds % 60
	# Format as MM:SS with leading zeroes
	timer_label.text = "%02d:%02d" % [minutes, rem_seconds]

func _on_kill_count_updated(total_kills: int) -> void:
	kill_label.text = str("💀", total_kills)

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
	hp_bar.set_hp_bar(current_hp, max_hp)


func _on_player_xp_updated(current_exp: int, max_exp: int) -> void:
	exp_bar.set_exp_bar(current_exp, max_exp)


func _on_player_leveled_up(new_level: int) -> void:
	exp_bar.set_level_label(new_level)
	reset_joystick()
	lvl_up_screen.show_level_up_menu(new_level)


func _on_player_level_up_choice_selected() -> void:
	lvl_up_screen.hide_level_up_menu()
