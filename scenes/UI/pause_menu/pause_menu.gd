extends Control

# Drag and drop main game world scene here in the Inspector
@export var game_scene_path: String = "res://scenes/world.tscn"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var menu_buttons: Control = %MenuButtons
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton

# Tracks what should happen after the "close" screen wipe finishes
var next_action: String = ""

func _ready() -> void:
	# CRITICAL: Ensures this menu and its animations run even while get_tree().paused == true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.size_changed.connect(_resize_to_fill_screen)
	_resize_to_fill_screen()
	
	# 1. Hide interactive buttons during the opening animation
	menu_buttons.hide()
	
	# 2. Connect button & animation signals
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# 3. Start the opening animation (Fixed from "boot_up")
	animated_sprite.play("open")

func _resize_to_fill_screen() -> void:
	var screen_size := get_viewport_rect().size
	# Fixed texture check from "boot_up" to "open"
	var texture := animated_sprite.sprite_frames.get_frame_texture("open", 0)
	if texture == null:
		return
	var frame_size := texture.get_size()
	var scale_factor := screen_size / frame_size
	animated_sprite.scale = scale_factor
	animated_sprite.position = screen_size / 2.0

func _on_animation_finished() -> void:
	match animated_sprite.animation:
		"open":
			# Opening animation done -> reveal menu buttons and allow clicking
			menu_buttons.show()
			resume_button.grab_focus()
		"close":
			# Closing animation done -> unpause the game and execute the action
			get_tree().paused = false
			if next_action == "resume":
				queue_free() # Destroys the pause menu so gameplay resumes
			elif next_action == "restart":
				get_tree().reload_current_scene() # Reloads the stage from scratch

func _on_resume_pressed() -> void:
	# Lock UI so buttons can't be spammed while closing
	menu_buttons.hide()
	next_action = "resume"
	animated_sprite.play("close")

func _on_restart_pressed() -> void:
	menu_buttons.hide()
	next_action = "restart"
	animated_sprite.play("close")
