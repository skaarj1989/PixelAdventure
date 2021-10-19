extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, WALK, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(Facing) var _facing = Facing.LEFT
export(float) var _speed = 0.5 # Tiles/sec

var _state
var _velocity := Vector2.ZERO
var _last_velocity := _velocity # Before collision
var _patrol_points = [] # [0] = left, [1] = right


onready var _shell_prefab := preload("Shell.tscn")

func _ready() -> void:
	_change_state(WALK)


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	_velocity.y += GameState.GRAVITY * delta
	_last_velocity = _velocity
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if _state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	_velocity = Vector2(
		-_facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity # Don't stop moving on collision
		elif collision.normal.x != 0:
			_change_state(IDLE)


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("idle")
			_velocity.x = 0
			$Timer.start()
		WALK:
			$AnimatedSprite.play("walk")
			$AnimatedSprite.flip_h = _facing == Facing.RIGHT
			_velocity.x = _facing * _speed * GameState.TILE_SIZE
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			yield($AnimatedSprite, "animation_finished")
			_leave_shell()
		
	_state = new_state


func _leave_shell() -> void:
	$AnimatedSprite.play("naked")
	var shell = _shell_prefab.instance()
	shell.position = position
	shell._facing = _facing
	get_parent().add_child(shell)


func _on_Timer_timeout() -> void:
	_facing = -_facing
	_change_state(WALK)
