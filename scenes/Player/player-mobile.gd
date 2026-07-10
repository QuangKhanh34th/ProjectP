class_name Player
extends CharacterBody2D

# --- Player stats ---
@export var speed : float = 50
@export var hp = 100



# --- Variable initialization ---
# Enemy related
var enemy_close: Array[Node2D] = []
var move_vector := Vector2.ZERO



# --- Movement ---
# calls every frame to process character movement (read movement input from user 
# and move the character)
func _process(delta: float) -> void:
	## Movement using the joystick output: (not used since we use one-joystick method)
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta

	## Rotation: (not used since we use one-joystick method)
#	if joystick_right and joystick_right.is_pressed:
#		rotation = joystick_right.output.angle()
	
	## Movement using Input functions (used by Virtual Joystick code):
	move_vector = Vector2.ZERO
	move_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	position += move_vector * speed * delta
	



# --- Radar ---
# When Enemy go into detection area 
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func get_nearby_enemies() -> Array[Node2D]:
	return enemy_close



# --- Health ---
# Get the "hurt" signal from the hurtbox, take the signal's value (damage)
# and subtract it into player's hp
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	print(hp)
