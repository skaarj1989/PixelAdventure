extends ParallaxBackground

export(float) var scrolling_speed := 0.5 # Tiles/sec


onready var _backgrounds = [
	preload("res://assets/Background/blue.png"),
	preload("res://assets/Background/brown.png"),
	preload("res://assets/Background/gray.png"),
	preload("res://assets/Background/green.png"),
	preload("res://assets/Background/pink.png"),
	preload("res://assets/Background/purple.png"),
	preload("res://assets/Background/yellow.png")
]

func _ready() -> void:
	var bg = GameState.pick_random_item(_backgrounds)
	$ParallaxLayer/Sprite.tile_set.tile_set_texture(0, bg)


func _process(delta: float) -> void:
	$ParallaxLayer.motion_offset.y += scrolling_speed * GameState.TILE_SIZE * delta
