extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, RUN, ATTACK, HIT}
const MAX_SIGHT_DISTANCE := 10 # In tiles
const RELOAD_SPEED := 0.5 # In seconds
const ROTATE_SPEED := 160.0 # Degrees/sec (on death)

export(Facing) var _facing = Facing.RIGHT
export(float) var _speed = 1.1
# (optional) Line2D that holds exactly 2 points
export(NodePath) var _patrol_path

var _state
var _can_shoot := true
var _continue_same_path := true # After attacking the player
var _velocity := Vector2.ZERO
var _patrol_points = [] # [0] = left, [1] = right


func _ready() -> void:
	if _patrol_path:
		_setup_patrol_points()
	_change_state(RUN)


func _process(_delta: float) -> void:
	if _state != HIT:
		if _patrol_path and _is_patrol_point_reached():
			_continue_same_path = false # Turn around
			_change_state(IDLE)
	else:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	_velocity.y += GameState.GRAVITY * delta
	_velocity = move_and_slide(_velocity, Vector2.UP)
	match _state:
		IDLE, RUN:
			_check_perimeter()
			continue
		IDLE, RUN, ATTACK:
			_check_collisions()


func take_damage(_from : Vector2 = Vector2.ZERO) -> bool:
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


func _is_patrol_point_reached() -> bool:
	# Remaps facing to: [0, 1] = [left, right]
	var target = _patrol_points[float(_facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if _facing == Facing.RIGHT else distance > 0 


func _check_perimeter() -> void:
	$RayCast2D.cast_to = Vector2(
			_facing * MAX_SIGHT_DISTANCE * GameState.TILE_SIZE,
			0.0
	)
	$RayCast2D.enabled = true
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider.is_in_group("player"):
			_change_state(ATTACK)


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		# Don't have to check for collisions against player,
		# this enemy is unlikely to step on the player
		if collision.normal.x != 0:
			_continue_same_path = false # turn around
			_change_state(IDLE)
			return


func _shot() -> void:
	var bullet = GameState.shot_bullet(
			"Trunk",
			position + Vector2(_facing * 19, 4),
			Vector2(_facing, 0) * GameState.TILE_SIZE * 6
	)
	get_parent().add_child(bullet)
	$Shot.play()
	_can_shoot = false


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimationPlayer.play("idle")
			_velocity.x = 0
			$Timer.start()
		RUN:
			$AnimationPlayer.play("run")
			$Sprite.flip_h = _facing == Facing.RIGHT
			_velocity.x = _facing * _speed * GameState.TILE_SIZE
		ATTACK:
			$AnimationPlayer.play("attack")
			_velocity.x = 0
			$Timer.stop()
		HIT:
			$AnimationPlayer.play("hit")
			$CollisionShape2D.disabled = true
			$RayCast2D.enabled = false
			$Timer.stop()
			$Reload.stop()
	
	_state = new_state


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		_continue_same_path = true
		_change_state(IDLE)
		$Reload.start(RELOAD_SPEED)


func _on_Timer_timeout() -> void:
	if not _continue_same_path:
		_facing = -_facing
	_change_state(RUN)


func _on_Reload_timeout() -> void:
	_can_shoot = true
