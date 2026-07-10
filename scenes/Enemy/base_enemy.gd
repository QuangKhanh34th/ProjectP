# A Base enemy class every other enemy we develop in the future can use
# include basic stats like movspd and hp, player-finding AI, take damage and be killed

class_name BaseEnemy
extends CharacterBody2D

@export var move_speed = 20.0
@export var hp = 10
var player = null

func _ready(): # can use @onready for the same effect
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta): # underscore in delta mean not use delta for this func
	if player:
		# Move directly toward the player
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * move_speed
		move_and_slide()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free() # Destroys the enemy


# Get the "hurt" signal from the hurtbox, take the signal's value (damage)
# and subtract it into enemy's hp, free the enemy node (kill it) when hp reached below 0
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	if hp < 0:
		queue_free()
