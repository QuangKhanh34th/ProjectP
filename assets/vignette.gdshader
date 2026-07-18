shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.85, 0.05, 0.05, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // Controlled by GDScript (0 = off, 1 = on)
uniform float pulse_speed : hint_range(1.0, 20.0) = 8.0;

void fragment() {
    // Calculate distance from screen center (0.5, 0.5)
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Create a continuous rhythmic heartbeat pulse using TIME
    float pulse = (sin(TIME * pulse_speed) * 0.15) + 0.85;
    
    // Smoothly ramp up alpha at the edges of the screen while keeping the center clear
    float edge = smoothstep(0.2, 0.7, dist) * intensity * pulse;
    
    COLOR = vec4(vignette_color.rgb, edge * vignette_color.a);
}