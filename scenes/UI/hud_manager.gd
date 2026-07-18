extends Control

# --- fullscreen ---
@onready var vignette = %Vignette

# --- top left group ---
@onready var exp_bar = %ExpBar
@onready var lvl_up_screen = $LevelUpContainer
@onready var hp_bar = %HPBar

# --- top center group ---
@onready var timer_label = %Timer
@onready var kill_label = %Kill

# --- bottom left group ---
@onready var weapon_slots: Array = %WeaponsColumn.get_children()
@onready var passive_slots: Array = %PassivesColumn.get_children()
# Dictionary maps display_name (e.g. "Shima Bun") -> ItemSlot UI Node
var owned_weapons: Dictionary = {}
var owned_passives: Dictionary = {}

func _ready() -> void:
	# Connect to the global Stage Manager broadcasts
	SignalBus.stage_time_updated.connect(_on_stage_time_updated)
	SignalBus.kill_count_updated.connect(_on_kill_count_updated)
	SignalBus.upgrade_collected.connect(_on_upgrade_collected)
	
	# Initialize labels on startup
	_on_stage_time_updated(300)
	_on_kill_count_updated(0)
	
	# Fetch existing weapons to fix the startup race condition
	var upgrade_manager = get_tree().current_scene.get_node_or_null("UpgradeManager")
	if upgrade_manager:
		for upgrade in upgrade_manager.collected_upgrades:
			#print("inventory: ", upgrade)
			_on_upgrade_collected(upgrade)

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

func _on_upgrade_collected(upgrade: UpgradeData) -> void:
	#print("inventory, signal received")
	# 1. Check if this is a weapon or a passive item
	if upgrade.type == "weapon":
		_assign_to_grid(upgrade, owned_weapons, weapon_slots)
		#print("inventory, owned weapons ", owned_weapons, " weapon slot  ", weapon_slots)
	else:
		# Handles "passive_item" or any other non-weapon type
		_assign_to_grid(upgrade, owned_passives, passive_slots)

func _assign_to_grid(upgrade: UpgradeData, owned_dict: Dictionary, slot_array: Array) -> void:
	#print("inventory, assign to grid called, parameter list\n", upgrade, "\n", owned_dict, "\n", slot_array)
	# Case A: We already own this weapon/passive. Just update the Level Label!
	if owned_dict.has(upgrade.display_name):
		#print("inventory, has upgrade called", upgrade.display_name)
		owned_dict[upgrade.display_name].update_slot(upgrade)
		return

	#print("inventory, not case A")
# Case B: Brand new item! Find the first empty slot in the column.
	for slot in slot_array:
		if slot.has_method("set_slot") and slot.is_empty:
			print("inventory, slot is empty", upgrade.display_name)
			slot.set_slot(upgrade)
			owned_dict[upgrade.display_name] = slot
			break

# TODO: Add player actual death
func _on_player_health_updated(current_hp: int, max_hp: int) -> void:
	hp_bar.set_hp_bar(current_hp, max_hp)
	
	# Calculate HP percentage
	var hp_percent := float(current_hp) / float(max_hp)
	var is_low_hp := (hp_percent <= 0.25 and current_hp > 0)

	# Smoothly fade the Vignette shader in or out
	if vignette and vignette.material is ShaderMaterial:
		var target_intensity := 0.35 if is_low_hp else 0.0
		var tween := create_tween()
		tween.tween_property(vignette.material, "shader_parameter/intensity", target_intensity, 0.25)


func _on_player_xp_updated(current_exp: int, max_exp: int) -> void:
	exp_bar.set_exp_bar(current_exp, max_exp)


func _on_player_leveled_up(new_level: int) -> void:
	exp_bar.set_level_label(new_level)
	reset_joystick()
	lvl_up_screen.show_level_up_menu(new_level)


func _on_player_level_up_choice_selected() -> void:
	lvl_up_screen.hide_level_up_menu()
