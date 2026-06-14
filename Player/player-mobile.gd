extends CharacterBody2D

@export var speed : float = 50
@export var hp = 100

# Attacks
var shimaBun = preload("res://Player/Attack/shima_bun.tscn")

# AttackNodes
@onready var ShimaBunTimer = get_node("Attack/ShimaBunTimer")
@onready var ShimaBunAttackTimer = get_node("Attack/ShimaBunTimer/ShimaBunAttackTimer")

# ShimaBun
var shimaBun_ammo = 0
var shimaBun_baseammo = 2
var shimaBun_attackspeed = 1.5
var shimaBun_level = 1

# Enemy related
var enemy_close = []

@export var joystick_left : VirtualJoystick
@export var joystick_right : VirtualJoystick

var move_vector := Vector2.ZERO

# When the player is loaded into the game, start attack() immediately
func _ready() -> void:
	attack()

# start the weapon timer if the weapon level is above 0 (meaning having/acquired 
# the weapon). Change this in the future if the starting weapon is changed
func attack():
	if shimaBun_level > 0:
		ShimaBunTimer.wait_time = shimaBun_attackspeed
		if ShimaBunTimer.is_stopped():
			ShimaBunTimer.start()

func _on_shima_bun_timer_timeout() -> void:
	shimaBun_ammo += shimaBun_baseammo
	ShimaBunAttackTimer.start()


func _on_shima_bun_attack_timer_timeout() -> void:
	if shimaBun_ammo > 0:
		var shimaBun_attack = shimaBun.instantiate()
		shimaBun_attack.position = position
		shimaBun_attack.target = get_target()
		shimaBun_attack.level = shimaBun_level
		add_child(shimaBun_attack)
		shimaBun_ammo -= 1
		if (shimaBun_ammo) > 0:
			ShimaBunAttackTimer.start()
		else:
			ShimaBunAttackTimer.stop()
		
func get_target()->Vector2:
	if enemy_close.size() > 0:
		return get_closest_enemy(global_position, enemy_close).global_position
	else:
		return Vector2.UP


func get_closest_enemy(current_position: Vector2, enemies):
	var closest_enemy = null
	var closest_distance:float = 1e20  # Initialize with a large number
	
	for enemy in enemies:
		var distance = current_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy	
	return closest_enemy
		

# When Enemy go into detection area
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


# calls every frame to process character movement (read movement input from user 
# and move the character)
func _process(delta: float) -> void:
	## Movement using the joystick output:
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta
	
	## Movement using Input functions:
	move_vector = Vector2.ZERO
	move_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	position += move_vector * speed * delta
	
	# Rotation:
	if joystick_right and joystick_right.is_pressed:
		rotation = joystick_right.output.angle()

# Get the "hurt" signal from the hurtbox, take the signal's value (damage)
# and subtract it into player's hp
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	print(hp)
