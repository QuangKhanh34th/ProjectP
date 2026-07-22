# This script manage all loot spawn, including xp orbs, destructible objects, pickups

extends Node2D

@onready var loot_base = get_tree().get_first_node_in_group("loot")

var drop_accumulator: float = 0.0
var exp_accumulator: int = 0 # track pooled HP

const EXP_GEM_SCENE = preload("res://scenes/objects/exp_gem.tscn")
const MAGNET_SCENE = preload("res://scenes/objects/magnet.tscn")

func _ready() -> void:
	SignalBus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Node2D) -> void:
	if randf() <= enemy.drop_value:
		spawn_exp_gem(enemy)
	
	if randf() <= enemy.magnet_drop_value:
		spawn_magnet(enemy)
	# TODO: Implement optimization logic when enemy spawn and exp gem spawn too much  
	# accumulator_exp_calculate(enemy)


func accumulator_exp_calculate(enemy: Node2D) -> void:
	drop_accumulator += enemy.drop_value
	exp_accumulator += enemy.experience
	
	while drop_accumulator >= 1.0:
		drop_accumulator -= 1.0
		spawn_exp_gem(enemy, exp_accumulator)
		
	exp_accumulator = 0

# assign default value to argument to make it optional
func spawn_exp_gem(enemy: Node2D, exp_amount: int = 0) -> void:
	var exp_drop = EXP_GEM_SCENE.instantiate()
	
	# drop exp gem where the enemy died
	exp_drop.global_position = enemy.global_position
	
	# if exp_amount is not specified
	if (exp_amount == 0):
		# assign enemy's base experience to exp gem
		exp_drop.experience = enemy.experience
	else:
		exp_drop.experience = exp_amount
	
	# spawn the gem
	loot_base.call_deferred("add_child", exp_drop)
	
func spawn_magnet(enemy: Node2D) -> void:
	var magnet_drop = MAGNET_SCENE.instantiate()
	magnet_drop.global_position = enemy.global_position
	loot_base.call_deferred("add_child", magnet_drop)
