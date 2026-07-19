extends Control

# Drag and drop your Start Screen scene here in the Inspector
@export var start_screen_path: String = "res://scenes/ui/start_game/control.tscn"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var menu_buttons: Control = %MenuButtons
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton

# Tracks what should happen after the "close" animation finishes
var next_action: String = ""

func _ready() -> void:
	# CRITICAL: Ensures the Game Over screen runs while get_tree().paused == true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.size_changed.connect(_resize_to_fill_screen)
	_resize_to_fill_screen()
	
	# 1. Hide interactive buttons during the opening death/wipe animation
	menu_buttons.hide()
	
	# 2. Connect button & animation signals
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# 3. Start your game over opening animation (e.g., "open" or "game_over")
	animated_sprite.play("open")

func _resize_to_fill_screen() -> void:
	var screen_size := get_viewport_rect().size
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
			# Opening wipe done -> reveal buttons and allow clicking
			menu_buttons.show()
			restart_button.grab_focus()
		"close":
			# Closing wipe done -> unpause the tree and execute the route
			get_tree().paused = false
			if next_action == "restart":
				get_tree().reload_current_scene() # Reload stage from scratch
			elif next_action == "quit":
				if not start_screen_path.is_empty():
					get_tree().change_scene_to_file(start_screen_path) # Return to main menu
				else:
					get_tree().quit()

func _on_restart_pressed() -> void:
	menu_buttons.hide()
	next_action = "restart"
	animated_sprite.play("close")

func _on_quit_pressed() -> void:
	menu_buttons.hide()
	next_action = "quit"
	animated_sprite.play("close")
