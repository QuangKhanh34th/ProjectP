extends CharacterBody2D

var move_speed = 40
@export var hp = 100

# run every frame (1/60 second) 
func _physics_process(delta):
	movement()

# Example: Assuming 'D' (right) is being pressed	
func movement():
	# x_mov = 1-0 = 1
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# y_mov = 0-0 = 0
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# => mov = Vector2(1,0)
	var mov = Vector2(x_mov, y_mov) 
	
	# => velocity = Vector2(1,0)*40 = Vector2(40,0)
	velocity = mov.normalized()*move_speed
	
	# Built-in function, move the character by the defined velocity
	# currently, the velocity is Vector2(40,0), meaning moving character to the position x=40, y=0,
	# which is the right side of the screen
	move_and_slide()
