# read spawn_info.gd first to better understand this spawner script 

extends Node2D

@export var spawns: Array[Spawn_Info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0



func _on_timer_timeout() -> void:
	# default to 1 second per spawn
	time += 1
	var enemy_spawns = spawns
	
	# --- OPTIMIZATION: Fetch Camera and Viewport data ONLY ONCE per second ---
	var camera = get_viewport().get_camera_2d()
	var zoom = camera.zoom if camera else Vector2.ONE
	var base_viewport_size = get_viewport_rect().size / zoom
	var player_pos = player.global_position
	# -------------------------------------------------------------------------
	
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
					var enemy_spawn = new_enemy.instantiate()
					# custom function, choose one of the 4 rectangle sides located just outside the player
					# view to spawn in
					# Pass the pre-calculated data into the function!
					enemy_spawn.global_position = get_random_position(base_viewport_size, player_pos) 
					add_child(enemy_spawn) # add enemy into World
					counter += 1 

# We now pass the pre-calculated data as arguments
func get_random_position(base_viewport_size: Vector2, player_pos: Vector2) ->Vector2:

	# Create a spawning zone that is outside the player screen, so
	# enemy never just "pop" into existence right before their eye
	var vpr = base_viewport_size * randf_range(1.1, 1.4)
	
	# Pin the spawning zone to move with the player, so they never step out of it
	# the math: minus/plus x = move to the left/right, minus/plus y = move up/down
	# for the top_left example, take player's position and move left by half the width (- vpr.x/2) 
	# and up by half the height (- vpr.y/2), we get top left corner
	var top_left = Vector2(player_pos.x - vpr.x/2, player_pos.y - vpr.y/2)
	var top_right = Vector2(player_pos.x + vpr.x/2, player_pos.y - vpr.y/2)
	var bottom_left = Vector2(player_pos.x - vpr.x/2, player_pos.y + vpr.y/2)
	var bottom_right = Vector2(player_pos.x + vpr.x/2, player_pos.y + vpr.y/2)
	
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
	
