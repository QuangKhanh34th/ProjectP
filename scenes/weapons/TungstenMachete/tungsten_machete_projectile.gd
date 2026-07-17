extends MeleeProjectile

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# 1. Run AOEProjectile's _ready() to initialize size
	super()
	
	# 3. Play the slash animation
	animated_sprite.frame = 0
	animated_sprite.play()
	
	# delete the hitbox when the animation ends

	animated_sprite.animation_finished.connect(cleanup_attack)
