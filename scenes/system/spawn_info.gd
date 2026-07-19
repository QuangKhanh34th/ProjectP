extends Resource

class_name Spawn_Info

@export var time_start:int # when to spawn
@export var time_end:int # when to NOT spawn anymore
@export var enemy:Resource # what type of enemy will be spawned
@export var enemy_num:int # how many enemy can be spawned per xxx second(s) (this depend on the code in enemy_spawner.gd)
@export var enemy_spawn_delay:int # seconds of delay between each spawn

var spawn_delay_counter = 0 # internal var to check the delayed seconds


# --- NEW: Optional Stat Overrides (0 = use default script stats) ---
@export_group("Stat Overrides (0 = Default)")
@export var custom_hp: int = 0
@export var custom_move_speed: float = 0.0
@export var custom_damage: int = 0
@export var custom_experience: int = 0
@export var custom_drop_value: float = -1.0 # -1.0 means default since drop_value can naturally be 0.0
