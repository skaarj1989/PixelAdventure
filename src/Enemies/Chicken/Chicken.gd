extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/sec (on death)
const THINK_INTERVAL := 0.5 # In seconds

export(Facing) var _facing = Facing.RIGHT
export(float) var _speed = 4.0 # Tiles/sec
export(float) var _horizontal_sight_extent = 6.0
export(NodePath) var _farm_path # (optional) Line2D

var _state
var _velocity := Vector2.ZERO
var _last_velocity := _velocity
var _chased_target
var _farm_points = []


func _ready() -> void:
	$AggroArea/CollisionShape2D.shape.extents.x = _horizontal_sight_extent * GameState.TILE_SIZE
	if _farm_path:
		_setup_farm()
	_change_state(IDLE)


func _process(_delta: float) -> void:
	match _state:
		RUN:
			_velocity.x = _facing * _speed * GameState.TILE_SIZE
		HIT:
			rotation_degrees += -_facing * ROTATE_SPEED * _delta
			if GameState.is_outside(position):
				queue_free()


func _physics_process(delta: float) -> void:
	_velocity.y += GameState.GRAVITY * delta
	_last_velocity = _velocity
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if _state != HIT:
		if _is_farm_edge_reached():
			_change_state(IDLE)
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	_velocity = Vector2(
		-_facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_farm() -> void:
	_farm_points = Array(get_node(_farm_path).get_points())
	assert(_farm_points.size() == 2)
	_farm_points.sort() # Left to right


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity
			return
		elif collision.normal.x != 0:
			_change_state(IDLE)


func _change_state(new_state) -> void:
	if _state == new_state:
		return
		
	match new_state:
		IDLE:
			$Label.text = "IDLE"
			$AnimatedSprite.play("idle")
			_velocity = Vector2.ZERO
		RUN:
			$Label.text = "RUN"
			$AnimatedSprite.play("run")
		HIT:
			$Label.text = "HIT"
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$AggroArea/CollisionShape2D.disabled = true
			$Timer.stop()

	_state = new_state


func _think() -> void:
	_face_the_target()
	if not _is_farm_edge_reached():
		_change_state(RUN)
	$Timer.start(THINK_INTERVAL)


func _is_farm_edge_reached() -> bool:
	if not _farm_path:
		return false
	
	var target = _farm_points[float(_facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if _facing == Facing.RIGHT else distance > 0 


func _face_the_target() -> void:
	if _chased_target:
		_facing = sign((_chased_target.position - position).x)
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		_chased_target = body
		_think()


func _on_AggroArea_body_exited(body) -> void:
	if _state != HIT and body.is_in_group("player"):
		_change_state(IDLE)
		_chased_target = null
		$Timer.stop()


func _on_Timer_timeout() -> void:
	_think()
