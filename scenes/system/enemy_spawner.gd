# read spawn_info.gd first to better understand this spawner script 

extends Node2D

@export var spawns: Array[Spawn_Info] = []

@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_camera = player.get_node("Camera2D")
@onready var base_enemy = $BaseEnemy

var time = 0
const MAX_SPAWN = 300

func _ready() -> void:
	SignalBus.enemy_exited_screen.connect(_on_enemy_exited_screen)

func _on_timer_timeout() -> void:
	# default to 1 second per spawn
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		# only do these code in between the start and end time
		if time >= i.time_start and time <= i.time_end:
			# Code for delayed spawn (spawn new enemy batch between 1,2,3,.. seconds)
			# if there is a spawn delay configured and the internal delay counter is not reached this 
			# spawn delay number yet
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1 # increase the internal delay counter by 1
			else: # when spawn delay time reached the configured spawn delay
				# 1. reset the timer
				i.spawn_delay_counter = 0
				
				# 2. spawn in the chosen enemy based on the amount we chose at random 
				# pos outside of the camera
				var new_enemy = i.enemy
				var counter = 0
				# spawn until the configured enemy number per spawn is reached 
				while counter < i.enemy_num:
					if get_tree().get_node_count_in_group("enemy") >= MAX_SPAWN:
						break

					var enemy_spawn = new_enemy.instantiate()
					
					# custom function, choose one of the 4 rectangle sides located just outside the player
					# view to spawn in
					enemy_spawn.global_position = get_random_position() 
					
					# inject necessary info to prevent lookup in enemy script
					enemy_spawn.player = player
					enemy_spawn.player_camera = player_camera
					
					
					
					add_child(enemy_spawn) # add enemy into World
					counter += 1 

func get_random_position():
	# Grab the currently active Camera2D in the scene and
	# get the screen size
	var camera = player_camera
	var zoom = camera.zoom if camera else Vector2.ONE
	
	# Create a spawning zone that is outside the player screen, so
	# enemy never just "pop" into existence right before their eye
	var vpr = (get_viewport_rect().size / zoom) * randf_range(1.1,1.4)
	
	# Pin the spawning zone to move with the player, so they never step out of it
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	
	# Choose an edge postion to spawn the enemy at
	var pos_size = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_size:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
			
	# randomize the position within the chosen edge
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)
	

func _on_enemy_exited_screen(enemy: Node2D):
	print("enemy exited spawn zone, disposing")
	enemy.queue_free()
