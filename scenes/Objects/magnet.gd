extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

# target is player
var target: Player = null
var speed = -1
const MAGNET_FLY_SPEED = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	# for every game tick...
	# if player picked up exp gem
	if target != null:
		# move toward player
		# for the first tick, since this line run first and inital speed is a negative value
		# the game will actually make the gem fly backward
		global_position = global_position.move_toward(target.global_position, speed)
		
		# increase the gem's speed exponentially
		speed += MAGNET_FLY_SPEED*delta
		
func collect() -> int:
	sound.play() 
	# disable collision
	collision.call_deferred("set", "disabled", true)
	
	# make the gem invisible 
	sprite.visible = false
	
	magnet_pull()
	
	# refactor later, for now give player 0 exp when collecting magnet 
	return 0

func magnet_pull():
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		
	var grab_shape = target.grabAreaCollision.shape as CircleShape2D
	var original_radius = grab_shape.radius
	grab_shape.radius += 99999.0
	await get_tree().create_timer(0.1).timeout
	grab_shape.radius = original_radius
	queue_free()
