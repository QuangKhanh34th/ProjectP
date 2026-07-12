extends Area2D

@export var experience: int = 1

var exp_green = preload("res://assets/Textures/Items/Gems/Gem_blue.png")
var exp_blue = preload("res://assets/Textures/Items/Gems/Gem_green.png")
var exp_red = preload("res://assets/Textures/Items/Gems/Gem_red.png")

var target = null
var speed = 0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready() -> void:
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = exp_blue
	else: 
		sprite.texture = exp_red
