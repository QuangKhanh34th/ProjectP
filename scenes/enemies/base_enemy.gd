# A Base enemy class every other enemy we develop in the future can use
# include basic stats like movspd and hp, player-finding AI, take damage and be killed

class_name BaseEnemy
extends CharacterBody2D

@export var move_speed = 20.0
@export var hp = 10
@export var damage = 1
@export var experience = 1
@export var drop_value: float = 0.2 # exp drop rate, in percentage

# Can be injected by the Spawner to prevent scene-tree lookup stutter
var player: Node2D = null
var player_camera: Camera2D = null

@onready var hitbox: Area2D = $Hitbox
@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") if has_node("Sprite2D") else get_node_or_null("AnimatedSprite2D")

func _ready(): # can use @onready for the same effect
	# Fallback lookup only if the Spawner didn't inject them
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	# assign enemy damage stat to the collision damage hitbox
	if hitbox:
		hitbox.damage = self.damage


func _physics_process(_delta): # underscore in delta mean not use delta for this func
	if player:
		# Move directly toward the player
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * move_speed
		move_and_slide()
		
		# 2. Check if the enemy fell too far behind the player's camera
		check_reposition()

func check_reposition() -> void:
	if not player_camera:
		return
		
	# Get the visible screen size adjusted for the camera's zoom
	var zoom = player_camera.zoom if player_camera else Vector2.ONE
	var view_size = (get_viewport_rect().size / zoom)
	
	# Calculate the center-to-edge distance, multiplied by 1.5
	# (Since your spawn zone maxes out at 1.4x, 1.5x is safely outside the spawn ring)
	var despawn_bounds = (view_size / 2.0) * 1.5
	
	# Check horizontal and vertical distance from the camera center (player position)
	var diff = global_position - player.global_position
	if abs(diff.x) > despawn_bounds.x or abs(diff.y) > despawn_bounds.y:
		SignalBus.enemy_exited_screen.emit(self)
		
func death():
	flash_white()
	await get_tree().create_timer(0.05).timeout
	# LootSpawner catch this signal
	SignalBus.enemy_died.emit(self)
	queue_free()


# Get the "hurt" signal from the hurtbox, take the signal's value (damage)
# and subtract it into enemy's hp, free the enemy node (kill it) when hp reached below 0
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	flash_white()
	if hp <= 0:
		death()
		
func flash_white() -> void:
	# Safety check: make sure the sprite exists and actually has our ShaderMaterial attached
	if not sprite or not sprite.material is ShaderMaterial:
		return
		
	# Instantly snap the shader's flash modifier to 1.0 (100% solid white)
	sprite.material.set_shader_parameter("flash_modifier", 1.0)
	
	# Create a lightweight tween to smoothly fade it back to 0.0 over 0.15 seconds
	var tween = create_tween()
	tween.tween_interval(0.15) # Wait for 0.15 seconds
	tween.tween_callback(func(): sprite.material.set_shader_parameter("flash_modifier", 0.0))
	
# --- Apply custom wave stats from Spawn_Info ---
func apply_custom_stats(info: Spawn_Info) -> void:
	if info.custom_hp > 0:
		hp = info.custom_hp
	if info.custom_move_speed > 0.0:
		move_speed = info.custom_move_speed
	if info.custom_damage > 0:
		damage = info.custom_damage
	# Update the Hitbox collision damage so the new damage actually hurts the player
	if hitbox:
		hitbox.damage = self.damage
	if info.custom_experience > 0:
		experience = info.custom_experience
	if info.custom_drop_value >= 0.0:
		drop_value = info.custom_drop_value
