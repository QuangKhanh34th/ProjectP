extends Control

# Drag and drop main game world scene here in the Inspector
@export var game_scene_path: String = "res://scenes/world.tscn"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var menu_buttons: Control = %MenuButtons
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

# Tracks what should happen after the "button_clicked" screen wipe finishes
var next_action: String = ""

func _ready() -> void:
	get_tree().root.size_changed.connect(_resize_to_fill_screen)
	_resize_to_fill_screen()
	
	# 1. Hide interactive buttons during the boot sequence
	menu_buttons.hide()
	
	# 2. Connect signals
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# 3. Start the intro animation
	animated_sprite.play("boot_up")

func _resize_to_fill_screen() -> void:
	# Get the current dimensions of the player's game window
	var screen_size := get_viewport_rect().size
	
	# Grab the texture of the very first frame to measure its original pixel size
	var texture := animated_sprite.sprite_frames.get_frame_texture("boot_up", 0)
	if texture == null:
		return
	var frame_size := texture.get_size()
	
	# Calculate the exact scaling multiplier needed to match the screen
	var scale_factor := screen_size / frame_size
	
	# OPTION A: Stretch to fit exact window (may slightly distort pixel ratio on weird screens)
	animated_sprite.scale = scale_factor
	
	# OPTION B: Cover the screen while preserving aspect ratio
	# var max_scale := maxf(scale_factor.x, scale_factor.y)
	# animated_sprite.scale = Vector2(max_scale, max_scale)
	
	# Center the sprite perfectly in the middle of the screen
	animated_sprite.position = screen_size / 2.0

func _on_animation_finished() -> void:
	match animated_sprite.animation:
		"boot_up":
			# Switch to idle state and reveal the clickable UI overlay
			animated_sprite.play("idle_menu")
			menu_buttons.show()
			start_button.grab_focus()
			
		"button_clicked":
			# Screen wipe is done -> check which button triggered it
			if next_action == "start":
				animated_sprite.play("loading")
			elif next_action == "quit":
				get_tree().quit()
			
		"loading":
			# Loading is done -> transition to the game world
			if not game_scene_path.is_empty():
				get_tree().change_scene_to_file(game_scene_path)
			else:
				push_error("Game scene path is not assigned in StartScreen")

func _on_start_pressed() -> void:
	# Disable UI interaction immediately so Start can't be spammed
	menu_buttons.hide()
	
	next_action = "start"
	
	# Play the loading & wipe sequence
	animated_sprite.play("button_clicked")

func _on_quit_pressed() -> void:
	# 1. Lock UI
	menu_buttons.hide()
	
	next_action = "quit"
	
	get_tree().quit()

func _input(event: InputEvent) -> void:
	# Only allow skipping if running from the Godot Editor (debug mode)
	if OS.is_debug_build():
		# Press SPACE to instantly skip all animations and load the world
		if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
			# Prevent multiple triggers
			set_process_input(false) 
			
			if not game_scene_path.is_empty():
				get_tree().change_scene_to_file(game_scene_path)
			else:
				push_error("Game scene path is not assigned in StartScreen")
				
