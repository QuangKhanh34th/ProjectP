shader_type canvas_item;

// This parameter will receive scale values from GDScript
uniform vec2 tiling_factor = vec2(1.0, 1.0);

void fragment() {
    // Multiply the UV coordinates by the tiling factor so the texture repeats
    vec2 tiled_uv = UV * tiling_factor;
    COLOR = texture(TEXTURE, tiled_uv);
}