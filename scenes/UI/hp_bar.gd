extends TextureProgressBar


func set_hp_bar(current_hp: int, max_hp: int):
	self.max_value = max_hp
	self.value = current_hp
