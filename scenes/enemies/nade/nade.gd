extends BaseEnemy

# Because this extends BaseEnemy, it ALREADY has the move_speed, hp, 
# _ready, _physics_process, and take_damage functions built-in invisibly

func _ready():
	# Override the base stats for this specific enemy
	move_speed = 30.0 
	hp = 5
	damage = 1
	experience = 1
	drop_value = 0.5
	
	# MUST call super() to run the base class's _ready function (to find the player)
	# AND then we can do some unique stuffs for this enemy 
	# if super() is not called, we are just simply overriding 
	# the base class function's logic without running it
	super() 

# We can override _physics_process(), take_damage(),.. also if
# we want this enemy to behave differently from normal enemies
# like it can move in a specific unique pattern, be invincible for
# x sec(s) when hp reaches a specific number,..
func _physics_process(delta: float) -> void:
	# Run BaseEnemy's movement and reposition logic first
	super(delta)
	
	# Check if the player exists, then compare X positions directly with player
	# left and right stutter when enemy collide with each other
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
			sprite.play()
		elif player.global_position.x > global_position.x:
			sprite.play()
