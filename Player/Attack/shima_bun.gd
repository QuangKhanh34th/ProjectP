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
signal remove_from_array(object)

func _ready() -> void:
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
	
func enemy_hit(charge = 1):
	hp -= charge
	# putting emit_signal here mean making the projectile hit an enemy
	# multiple times as long as it still in contact with the enemy hurtbox
	# emit_signal("remove_from_array", self) 
	if hp <= 0:
		# clean up the already-removed projectile from hurtbox's hit_once_array
		# list so the list stay clean
		emit_signal("remove_from_array", self)
		queue_free() # hit enemy then disappear

# If the attack missed the target, disappear after 10s
func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free() 
