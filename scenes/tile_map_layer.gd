extends TileMapLayer

@export var mirror_size := Vector2i(1000, 1000)
@export var tile_size := Vector2i(8, 8)
# Replace with the atlas coordinates (Vector2i) of your desired background tile
@export var bg_tile_coords := Vector2i(0, 0) 

func _ready() -> void:
	var cols := mirror_size.x / tile_size.x
	var rows := mirror_size.y / tile_size.y
	
	for x in range(cols):
		for y in range(rows):
			# set_cell(coords, source_id, atlas_coords)
			set_cell(Vector2i(x, y), 0, bg_tile_coords)
