class_name StageManager
extends Node

var stage_time: int = 300 # in seconds
var kill_count: int = 0
# Create a 1-second internal timer
var second_timer := Timer.new()

func _ready() -> void:
	# Listen for enemy deaths globally
	SignalBus.enemy_died.connect(_on_enemy_died)
	
	
	second_timer.wait_time = 1.0
	second_timer.autostart = true
	second_timer.timeout.connect(_on_second_tick)
	add_child(second_timer)

func _on_second_tick() -> void:
	if stage_time > 0:
		stage_time -= 1
		SignalBus.stage_time_updated.emit(stage_time)
		
		# Check if the timer just hit zero
		if stage_time == 0:
			second_timer.stop()
			# Optional: Emit a signal when time runs out
			# SignalBus.stage_time_up.emit()

func _on_enemy_died(_enemy: Node2D) -> void:
	kill_count += 1
	SignalBus.kill_count_updated.emit(kill_count)
