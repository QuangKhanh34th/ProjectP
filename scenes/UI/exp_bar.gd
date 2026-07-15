extends TextureProgressBar

@onready var lbl_level: Label = %LevelLabel

func set_exp_bar(set_value = 1, set_max_value = 100):
	self.value = set_value
	self.max_value = set_max_value

func set_level_label(new_level: int):
	lbl_level.text = "Lv. " + str(new_level)
