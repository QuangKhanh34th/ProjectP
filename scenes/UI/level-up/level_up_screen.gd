extends MarginContainer

@onready var lvlPanel = %LevelUpPanel
@onready var upgradeOptions = %UpgradeOptions
@onready var itemOptions = preload("res://scenes/UI/level-up/item_option.tscn")
@onready var sndLevelUp = %snd_levelup

func show_level_up_menu(new_level: int) -> void:
	sndLevelUp.play()
	self.visible = true
	lvlPanel.visible = true
	get_tree().paused = true

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("Level-up menu could not find a Player node in the 'player' group.")
		return
	
	var options = 0
	var option_max = 3
	while (options < option_max):
		var option_choice = itemOptions.instantiate()
		option_choice.upgrade_selected.connect(player.upgrade_character)
		upgradeOptions.add_child(option_choice)
		#print("signal connected")
		options += 1
		
	var tween = self.create_tween()
	tween.tween_property(self, "position", Vector2(0,0), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	

func hide_level_up_menu() -> void:
	var option_childrens = upgradeOptions.get_children()
	for i in option_childrens:
		i.queue_free()
		
	# Hide the level up screen
	self.visible = false
	self.position = Vector2(1600, 0)
	lvlPanel.visible = false
	
	# Resume the game and allow new level-ups
	#is_leveling_up = false
	get_tree().paused = false
