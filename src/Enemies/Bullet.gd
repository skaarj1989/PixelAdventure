extends KinematicBody2D

var shooter_name: String = ""
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var last_velocity := velocity


onready var rng = RandomNumberGenerator.new()
onready var bullet_piece = preload("BulletPiece.tscn")

func _ready() -> void:
	assert(velocity != Vector2.ZERO and shooter_name != "")
	$Sprite.texture = load("res://assets/Enemies/%s/bullet.png" % shooter_name)


func _physics_process(_delta: float) -> void:
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	check_collisions()


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
		smash()


func smash() -> void:
	for i in range(2):
		var piece = bullet_piece.instance()
		var sprite = piece.get_node("Sprite")
		sprite.texture = load("res://assets/Enemies/%s/bullet_pieces.png" % shooter_name) 
		sprite.frame = i
		piece.position = position
		get_parent().add_child(piece)
		rng.randomize()
		var impulse = Vector2(
			rng.randf_range(0.1, 1.0) * -last_velocity.x + 0.5,
			rng.randf_range(-1.0, 1.0) * (last_velocity.y + 0.1) * 0.5
		)
		piece.apply_impulse(Vector2.ZERO, impulse)
		
		queue_free()
