extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(Facing) var _facing = Facing.RIGHT
export(float) var _speed = 1.5 # Tiles/sec
# (optional) Line2D that holds exactly 2 points
export(NodePath) var _patrol_path

var _state
var _velocity := Vector2.ZERO
var _last_velocity := _velocity # Before collision
var _patrol_points = [] # [0] = left, [1] = right


onready var _drop_prefab = preload("Drop.tscn")

func _ready() -> void:
	if _patrol_path:
		_setup_patrol_points()
	_change_state(RUN)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT
	
	match _state:
		RUN:
			_velocity.x = _facing * _speed * GameState.TILE_SIZE
			if _patrol_path and _is_patrol_point_reached():
				_facing = -_facing
		HIT:
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


func _setup_patrol_points() -> void:
	_patrol_points = Array(get_node(_patrol_path).get_points())
	assert(_patrol_points.size() == 2)
	_patrol_points.sort() # Left to right


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity # Don't stop movement on collision
			return
		elif collision.normal.x != 0:
			_facing = -_facing


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		RUN:
			$AnimatedSprite.play("idle-run")
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$Timer.stop()

	_state = new_state


func _is_patrol_point_reached() -> bool:
	# Remaps facing to: [0, 1] = [left, right]
	var target = _patrol_points[float(_facing) * 0.5 + 0.5]
	var distance = (target - position).x
	# TODO: Check if is on path for sure (compare .y coord)
	return distance < 0 if _facing == Facing.RIGHT else distance > 0 


func _on_Timer_timeout() -> void:
	var drop = _drop_prefab.instance()
	drop.position = position + Vector2(-_facing * 20, 14)
	get_parent().add_child(drop)
	$Timer.start()
