extends TileMapLayer

# Size of each chunk in tiles (16 * 8px = 128px)
# increase this to let the spawner have more space to put things
@export var chunk_size: Vector2i = Vector2i(8, 8) 
@export var render_distance: int = 3 # How many chunks in each direction to keep active around the player
@export var obstacle_spawn_chance: float = 0.30 # Chance per chunk to spawn a large obstacle/building

@onready var player: Node2D = get_tree().get_first_node_in_group("player")
const PLAYER_START_POS := Vector2i(0, 0)
const SAFE_RADIUS := 10 # Radius in tiles around the start to keep clear

# Keeps track of chunk coordinates (Vector2i) that have already been generated
var generated_chunks: Dictionary = {}

# Stores the Rect2i bounding box of every spawned building in the world
var occupied_building_rects: Array[Rect2i] = []

# Atlas coordinates of single-tile obstacles (like small rocks, consoles, skulls from texture)
# --- WEIGHTS FOR SINGLE TILE OBSTACLES ---
const OBSTACLE_WEIGHTS: Dictionary = {
	Vector2i(1, 0): 50, # grass 1
	Vector2i(2, 0): 50, # grass 2
	Vector2i(7, 0): 50, # grass 3
	Vector2i(8, 0): 50, # grass 4
	Vector2i(9, 0): 50, # grass 5
	Vector2i(10, 0): 50, # grass 6
	Vector2i(11, 0): 50, # grass 7 
	Vector2i(17, 9): 10, # skull
	Vector2i(18, 10): 30 # dead bush
}

# --- WEIGHTS FOR BIG BUILDINGS ---
# Higher weight = spawns more often. 
# 0, 1, and 2 are 10x more common than other patterns
const PATTERN_WEIGHTS: Dictionary = {
	0: 50, # Building 1
	1: 50, # Building 2 
	2: 50, # Building 3 
	3: 30, # Boxes
	4: 30, # Box
	5: 30, # Pool?
	6: 10 # Dead tree
}

# cache the total sum of all weights here for performance
var total_obstacle_weight: float = 0.0
var total_pattern_weight: float = 0.0

func _ready() -> void:
	# Calculate the total weight once when the game starts
	for weight in OBSTACLE_WEIGHTS.values():
		total_obstacle_weight += float(weight)
		
	# Calculate the total weight for building patterns
	for weight in PATTERN_WEIGHTS.values():
		total_pattern_weight += float(weight)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	# Calculate which chunk coordinate the player is currently standing in
	var player_tile_pos := local_to_map(player.global_position)
	var current_chunk := Vector2i(
		floori(float(player_tile_pos.x) / float(chunk_size.x)),
		floori(float(player_tile_pos.y) / float(chunk_size.y))
	)
	
	# Loop through the surrounding grid of chunks based on render_distance
	for x in range(current_chunk.x - render_distance, current_chunk.x + render_distance + 1):
		for y in range(current_chunk.y - render_distance, current_chunk.y + render_distance + 1):
			var chunk_coord := Vector2i(x, y)
			
			# If we haven't generated this chunk yet, generate it now
			if not generated_chunks.has(chunk_coord):
				generate_chunk(chunk_coord)
				generated_chunks[chunk_coord] = true

func generate_chunk(chunk_coord: Vector2i) -> void:
	var base_x := chunk_coord.x * chunk_size.x
	var base_y := chunk_coord.y * chunk_size.y
	
	# --- Spawn Multi-Tile Buildings FIRST ---
	if randf() < obstacle_spawn_chance:
		if tile_set and tile_set.get_patterns_count() > 0:
			var pattern_index := get_weighted_random_pattern()
			var pattern := tile_set.get_pattern(pattern_index)
			
			var random_offset := Vector2i(
				randi_range(2, chunk_size.x - 4),
				randi_range(2, chunk_size.y - 4)
			)
			var spawn_pos := Vector2i(base_x, base_y) + random_offset
			
			# check if spawn pos is near player starting point
			var dist_to_start := (spawn_pos - PLAYER_START_POS).length()
			if dist_to_start < SAFE_RADIUS:
				return # Don't spawn here, exit early
			
			# Create a Rect2i of the building's footprint
			var building_rect := Rect2i(spawn_pos, pattern.get_size())
				
			# Grow the rectangle by 2 tiles in all directions!
			# This forces a "buffer zone" so buildings can't spawn right next to each other
			var padded_rect := building_rect.grow(2)
			
			# Check if this area is completely free of other buildings
			if is_space_empty(padded_rect):
				set_pattern(spawn_pos, pattern)
				# Save the actual footprint so future chunks know not to build here
				occupied_building_rects.append(building_rect)
	
	# --- Scatter Single-Tile Obstacles SECOND ---
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var tile_pos := Vector2i(base_x + x, base_y + y)
			
			# Only spawn if the building didn't already place a tile here (-1 means empty)
			if get_cell_source_id(tile_pos) == -1:
				if randf() < 0.03: # 3% chance a tile spawns an obstacle at all
					# Pick the specific obstacle based on weights
					var random_obstacle := get_weighted_random_obstacle()
					set_cell(tile_pos, 0, random_obstacle)

func get_weighted_random_pattern() -> int:
	var roll := randf_range(0.0, total_pattern_weight)
	
	for pattern_id: int in PATTERN_WEIGHTS:
		roll -= float(PATTERN_WEIGHTS[pattern_id])
		if roll <= 0.0:
			return pattern_id
			
	# Fallback safety
	return PATTERN_WEIGHTS.keys().back()

func get_weighted_random_obstacle() -> Vector2i:
	# Roll a random number between 0.0 and the total weight (e.g., 96.0)
	var roll := randf_range(0.0, total_obstacle_weight)
	
	# Step through each obstacle and subtract its weight from the roll
	for atlas_coord: Vector2i in OBSTACLE_WEIGHTS:
		roll -= float(OBSTACLE_WEIGHTS[atlas_coord])
		if roll <= 0.0:
			return atlas_coord
			
	# Fallback safety in case of floating-point rounding errors
	return OBSTACLE_WEIGHTS.keys().back()
	
func is_space_empty(proposed_rect: Rect2i) -> bool:
	for existing_rect in occupied_building_rects:
		# If the new rectangle overlaps an existing one, the space is NOT empty!
		if proposed_rect.intersects(existing_rect):
			return false
	return true
