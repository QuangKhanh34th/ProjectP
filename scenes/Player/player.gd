class_name Player
extends CharacterBody2D

# --- Player stats ---
@export var player_level: int = 1
var experience: float = 0
var collected_experience: int = 0 # track number of exp orb that collected in one frame
var is_leveling_up: bool = false
@export var hp: int = 100
@export var move_speed: float = 50.0
@export var defense: int = 0

# global stats that will be add to weapon projectile calculation (in %, except for amount)
@export var power: float = 0.0
@export var speed: float = 0.0
@export var pierce: float = 0.0
@export var size: float = 0.0
@export var amount: int = 0
@export var duration: float = 0.0
@export var cooldown: float = 0.0


# --- GUI ---
@onready var ExpBar = get_node("%ExpBar") # get access to TextureProgressBar named ExpBar in the scene this script is hooked on to
@onready var LevelLabel = get_node("%LevelLabel") # same as ExpBar
@onready var LevelUpContainer = get_node("%LevelUpContainer")
@onready var LevelPanel = get_node("%LevelUpPanel")
@onready var UpgradeOptions = get_node("%UpgradeOptions")
@onready var ItemOption = load("res://scenes/Player/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")




# --- Variable initialization ---
# Enemy related
var enemy_close: Array[Node2D] = []
var move_vector := Vector2.ZERO

const SHIMA_BUN_WEAPON = preload("res://scenes/Player/Weapons/ShimaBun/shima_bun.tscn")

func _ready():
	if speed == null:
		speed = 50.0
	if hp == null:
		hp = 100
	$WeaponManager.add_weapon(SHIMA_BUN_WEAPON)
	set_exp_bar(experience, calculate_experience_cap())

# --- Movement ---
# calls every frame to process character movement (read movement input from user 
# and move the character)
func _process(delta: float) -> void:
	## Movement using the joystick output: (not used since we use one-joystick method)
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta

	## Rotation: (not used since we use one-joystick method)
#	if joystick_right and joystick_right.is_pressed:
#		rotation = joystick_right.output.angle()
	
	## Movement using Input functions (used by Virtual Joystick code):
	move_vector = Vector2.ZERO
	move_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	position += move_vector * move_speed * delta
	



# --- Radar ---
# When Enemy go into detection area 
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func get_nearby_enemies() -> Array[Node2D]:
	return enemy_close



# --- Health ---
# Get the "hurt" signal from the hurtbox, take the signal's value (damage)
# and subtract it into player's hp
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	print(hp)


# --- Exp Collecting ---
func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self
		area.set_physics_process(true)


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
		

func calculate_experience(gem_exp: int = 0):
	experience += gem_exp
	print("Collected ", gem_exp, " exp. Current exp: ", experience)
	
	var exp_required = calculate_experience_cap()
	
	# Only level up if we have enough XP AND the menu isn't already open
	if experience >= exp_required and not is_leveling_up:
		experience -= exp_required
		level_up()
	else:
		set_exp_bar(experience, exp_required)
	
	

func calculate_experience_cap() -> int:
	var exp_cap = player_level
	if player_level < 20:
		exp_cap = player_level*5
	elif player_level < 40:
		exp_cap = 95 + (player_level-19) * 8
	else:
		exp_cap = 255 + (player_level-39) * 12
	
	return exp_cap

func level_up():
	is_leveling_up = true
	sndLevelUp.play()
	player_level += 1  # <-- Only increment level HERE!
	print("[player-mobile.gd] Level up! New Level: ", player_level)
	LevelLabel.text = "Lv. " + str(player_level)
	reset_joystick()
	LevelUpContainer.visible = true
	LevelPanel.visible = true
	
	var options = 0
	var option_max = 3
	while (options < option_max):
		var option_choice = ItemOption.instantiate()
		UpgradeOptions.add_child(option_choice)
		option_choice.upgrade_selected.connect(upgrade_character)
		print("signal connected")
		options += 1
	
	get_tree().paused = true
	
	var tween = LevelUpContainer.create_tween()
	tween.tween_property(LevelUpContainer, "position", Vector2(0,0), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	
func reset_joystick():
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	move_vector = Vector2.ZERO
	
	# 2. Reset the virtual joystick visually and internally so the thumbstick snaps back to center
	var joystick = get_tree().current_scene.get_node_or_null("CanvasLayer/Virtual Joystick")
	if joystick and joystick.has_method("_reset"):
		joystick._reset()
		joystick.hide()

func set_exp_bar(set_value = 1, set_max_value = 100):
	ExpBar.value = set_value
	ExpBar.max_value = set_max_value
		

func upgrade_character(weapon_to_upgrade) -> void:
	var option_childrens = UpgradeOptions.get_children()
	for i in option_childrens:
		i.queue_free()
		
	# Hide the level up screen
	LevelUpContainer.visible = false
	LevelUpContainer.position = Vector2(1600, 0)
	LevelPanel.visible = false
	
	# Resume the game and allow new level-ups
	is_leveling_up = false
	get_tree().paused = false
	
	# Check if we still have enough banked XP for another level-up!
	calculate_experience(0)
	
