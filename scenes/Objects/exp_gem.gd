extends Area2D

@export var experience: int = 1

var exp_green = preload("res://assets/Textures/Items/Gems/Gem_blue.png")
var exp_blue = preload("res://assets/Textures/Items/Gems/Gem_green.png")
var exp_red = preload("res://assets/Textures/Items/Gems/Gem_red.png")

# target is player
var target = null
var speed = -1
const EXP_FLY_SPEED = 5
const GREEN_GEM_EXP_AMOUNT = 5
const BLUE_GEM_EXP_AMOUNT = 25

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready() -> void:
	set_physics_process(false)
	
	if experience < GREEN_GEM_EXP_AMOUNT:
		return
	elif experience < BLUE_GEM_EXP_AMOUNT:
		sprite.texture = exp_blue
	else: 
		sprite.texture = exp_red

func _physics_process(delta: float) -> void:
	# for every game tick...
	# if player picked up exp gem
	if target != null:
		# move toward player
		# for the first tick, since this line run first and inital speed is a negative value
		# the game will actually make the gem fly backward
		global_position = global_position.move_toward(target.global_position, speed)
		
		# increase the gem's speed exponentially
		speed += EXP_FLY_SPEED*delta
		
func collect() -> int:
	sound.play() 
	# disable collision
	collision.call_deferred("set", "disabled", true)
	
	# make the gem invisible 
	sprite.visible = false
	
	# return exp value
	return experience
	


func _on_snd_collected_finished() -> void:
	queue_free()
