extends WeaponBase

# --- Weapon Description ---
# deal damage in front of the player, once per attack
# damage affected by size
# not affected by speed, penetration, duration

@onready var cooldown_timer = $CooldownTimer
@onready var tungsten_machete_projectile_scene = preload("res://scenes/weapons/TungstenMachete/tungsten_machete_projectile.tscn")

# Map the player's 8 string directions to Godot radians (0 is Right, PI/2 is Down)
const DIRECTION_ANGLES := {
	"right": 0.0,
	"down_right": PI / 4.0,
	"down": PI / 2.0,
	"down_left": 3.0 * PI / 4.0,
	"left": PI,
	"up_left": -3.0 * PI / 4.0,
	"up": -PI / 2.0,
	"up_right": -PI / 4.0
}

const SPRITE_OFFSET := PI / 4.0

func _ready() -> void:
	print("machete", level)
	max_level = 8
	base_damage = 5.0
	base_size = 0.5
	base_ammo = 1
	base_cooldown = 1.0 # seconds
	base_delay = 0.05 # seconds, used when ammo above 1
	attack()

func level_up():
	level += 1
	
	# placeholder values, need changes later 
	match level:
		2:
			base_size += 0.3
		3:
			base_size += 50
		4:
			base_damage = 5.0
		5:
			base_damage = 5.0
		6:
			base_damage = 5.0
		7:
			base_damage = 5.0
		8:
			base_damage = 5.0

func attack() -> void:
	if level > 0:
		if cooldown_timer.is_stopped():
			cooldown_timer.wait_time = get_weapon_cooldown()
			print("wait time: ", cooldown_timer.wait_time)
			cooldown_timer.start()

# --- FIRING LOGIC ---
func _on_cooldown_timer_timeout() -> void:
	if not has_player():
		cooldown_timer.start(0.1)
		return


	# Instantiate the projectile
	var projectile = tungsten_machete_projectile_scene.instantiate()
	
	# Only pass the stats the weapon actually cares about
	projectile.damage_type = self.damage_type
	projectile.damage = get_weapon_damage()
	projectile.size = get_weapon_size() 
	
	
	
	# add as child of player to make the projectile move with them
	print("instantiate")
	add_child(projectile)
	projectile.position = Vector2.ZERO
	
	# Rotate the slash toward the player's currently faced direction
	var facing_dir = player.last_direction
	print("last direction: ", player.last_direction)
	if DIRECTION_ANGLES.has(facing_dir):
		projectile.rotation = DIRECTION_ANGLES[facing_dir] + SPRITE_OFFSET
	else:
		projectile.rotation = PI / 2.0 + SPRITE_OFFSET # Default to facing down if undefined
		
	projectile.tree_exited.connect(_on_projectile_finished)

# Restart cooldown for the next attack when queue_free() is used in projectile script
func _on_projectile_finished() -> void:
	cooldown_timer.wait_time = get_weapon_cooldown()
	cooldown_timer.start()
