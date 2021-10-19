extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, ATTACK, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(float) var _speed = 2.0 # Tiles/sec
export(NodePath) var _patrol_path # (mandatory) Path2D

var _state
var _velocity := Vector2.ZERO
var _last_velocity := _velocity
var _patrol_points = []
var _patrol_index := -1


func _ready() -> void:
	_setup_patrol_path()
	_change_state(IDLE)


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	if _state != HIT:
		var target = _patrol_points[_patrol_index]
		var d = position.distance_to(target)
		if d < 16:
			_patrol_index = wrapi(_patrol_index + 1, 0, _patrol_points.size())
			target = _patrol_points[_patrol_index]
			_velocity = (target - position).normalized() * _speed * GameState.TILE_SIZE
	else:
		_velocity.y += GameState.GRAVITY * delta
	
	_last_velocity = _velocity
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if _state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	_velocity = Vector2(
		-sign(_velocity.x),
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_patrol_path() -> void:
	assert(_patrol_path)
	_patrol_points = get_node(_patrol_path).curve.get_baked_points()
	var closest_point = GameState.get_closest_point(_patrol_points, position)
	_patrol_index = Array(_patrol_points).find(closest_point)


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			if collider.is_vulnerable_to(self):
				collider.take_damage(_last_velocity)
			_velocity = _last_velocity # Don't stop movement on collision


func _shoot() -> void:
	var bullet_speed = GameState.TILE_SIZE * 8
	var bullet = GameState.shot_bullet(
			"Bee",
			position + Vector2(0, 16),
			Vector2.DOWN * bullet_speed
	)
	get_parent().add_child(bullet)
	$Shot.play()


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimationPlayer.play("idle")
		ATTACK:
			$AnimationPlayer.play("attack")
		HIT:
			$AnimationPlayer.play("hit")
			$CollisionShape2D.disabled = true
			$AggroArea/CollisionShape2D.disabled = true
		
	_state = new_state


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		_change_state(ATTACK)


func _on_AggroArea_body_exited(body) -> void:
	if _state != HIT and body.is_in_group("player"):
		_change_state(IDLE)
