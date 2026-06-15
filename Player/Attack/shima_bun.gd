# Script for the weapon (or rather, the projectile) "ShimaBun". This node
# is an Area2D that is in the "attack" group, this mean it will acts like a hitbox
# and deal damage (emit "hurt" signal) when entering a hurtbox's area

# This hitbox exist on layer 3, meaning it will only enter (collide) hurtboxes that
# on collision mask 3. Currently, enemy's hurtboxes are on mask 3, that means the weapon/
# projectile will only hurt the enemy. We can change this to 2 if we want to enable friendly fire
extends Area2D

# Stat initialization, player start with this when the weapon is obtained
var level = 1
var hp = 1 # act like penetration level, get this number up and more enemy it will penetrate
var speed = 100
var damage = 10
var knock_amount = 100
var attack_size = 1.0

# variables describing which direction to shoot the projectile
# we get these numbers from player-mobile.gd when it call this script
var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

# 1. Create a variable to hold the start time
var spawn_time_msec: int = 0

func _ready() -> void:
	# 2. Record the exact millisecond the projectile is created
	spawn_time_msec = Time.get_ticks_msec()
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	# describe the stats for every level, for now there is only one level
	match level:
		1:
			hp = 1
			speed = 100
			damage = 20
			var knock_amount = 100
			var attack_size = 1.0
			
func _physics_process(delta: float) -> void:
	position += angle*speed*delta


# 3. Create a quick helper function to do the math and print it
func print_lifespan(freed_by: String) -> void:
	var current_time = Time.get_ticks_msec()
	# Subtract spawn time from current time, and divide by 1000 to get seconds
	var lifespan_seconds = (current_time - spawn_time_msec) / 1000.0
	print("Projectile freed by [", freed_by, "] after: ", lifespan_seconds, " seconds.")

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		# print_lifespan("Enemy Hit")
		queue_free() # hit enemy then disappear

# If the attack missed the target, disappear after 10s (old way)
#func _on_timer_timeout() -> void:
	#queue_free() 

# If the attack didn't hit any enemy and not visible to the player anymore
# disappear immediately (new way, help a bit more with the performance)
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# print_lifespan("Screen Exit")
	queue_free()
