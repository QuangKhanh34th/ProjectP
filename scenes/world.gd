extends Node2D


@onready var worldCamera = $DebugCamera

func _ready() -> void:
	if worldCamera.is_visible_in_tree() != false:
		worldCamera.make_current()
