extends BaseEnemy

# Because this extends BaseEnemy, it ALREADY has the move_speed, hp, 
# _ready, _physics_process, and take_damage functions built-in invisibly

func _ready():
	# MUST call super() to run the base class's _ready function (to find the player)
	# AND do some unique stuffs for this enemy, 
	super() 
	
	# Override the base stats for this specific enemy
	move_speed = 30.0 
	hp = 5
