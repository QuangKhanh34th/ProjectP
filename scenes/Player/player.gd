class_name Player
extends CharacterBody2D

# --- Animation & Movement Variables ---
var move_vector := Vector2.ZERO
var last_direction: String = "down" # Default starting direction
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Player stats ---
@export var player_level: int = 1
var experience: int = 0
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


# --- Signal ---
signal xp_updated(current_exp: int, max_exp: int)
signal leveled_up(new_level: int)
signal level_up_choice_selected
signal health_updated(current_hp: int, max_hp: int)






# --- Variable initialization ---
# Enemy related
var enemy_close: Array[Node2D] = []

const SHIMA_BUN_WEAPON = preload("res://scenes/weapons/ShimaBun/shima_bun.tscn")
const LASER_WEAPON = preload("res://scenes/weapons/Laser/laser.tscn")

func _ready():
	if speed == null:
		speed = 50.0
	if hp == null:
		hp = 100
	$WeaponManager.add_weapon(SHIMA_BUN_WEAPON)
	$WeaponManager.add_weapon(LASER_WEAPON)
	call_deferred("emit_signal", "xp_updated", experience, calculate_experience_cap())

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
	update_animation()
	

func update_animation() -> void:
	if move_vector != Vector2.ZERO:
		# 1. Define the 8 directions in clockwise order matching Godot's angle system
		var directions := [
			"right", "down_right", "down", "down_left", 
			"left", "up_left", "up", "up_right"
		]
		
		# 2. Convert the vector's angle into a clean integer index from 0 to 7
		var index := posmod(roundi(move_vector.angle() / (PI / 4.0)), 8)
		last_direction = directions[index]
		
		# NOTE: If you add walking animations later, change this to:
		# animated_sprite.play("walk_" + last_direction)
		animated_sprite.play("idle_" + last_direction)
	else:
		# 3. When standing still, play the idle animation of the last direction faced
		animated_sprite.play("idle_" + last_direction)

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
		

# --- Experience and Leveling ---
func calculate_experience(gem_exp: int = 0):
	experience += gem_exp
	print("Collected ", gem_exp, " exp. Current exp: ", experience)
	
	var exp_required = calculate_experience_cap()
	
	# Only level up if we have enough XP AND the menu isn't already open
	if experience >= exp_required and not is_leveling_up:
		experience -= exp_required
		level_up()
	else:
		xp_updated.emit(experience, exp_required)
	
	

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
	player_level += 1  
	print("[player-mobile.gd] Level up! New Level: ", player_level)
	leveled_up.emit(player_level)
	
	

func upgrade_character(weapon_to_upgrade) -> void:
	level_up_choice_selected.emit()
	
	# Resume the game and allow new level-ups
	is_leveling_up = false
	
	# Check if we still have enough banked XP for another level-up
	calculate_experience(0)
	
