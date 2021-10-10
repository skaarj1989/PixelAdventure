extends KinematicBody2D

enum {IDLE, RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/sec (on death)
const THINK_INTERVAL := 0.5 # In seconds

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var speed := 4.0
export(float) var horizontal_sight_extent = 4.0
export(NodePath) var farm_path # (optional) Line2D

var state
var velocity := Vector2.ZERO
var last_velocity := velocity
var chased_target
var farm_points = []


func _ready() -> void:
	$AggroArea/CollisionShape2D.shape.extents.x = horizontal_sight_extent * GameState.TILE_SIZE
	if farm_path:
		_setup_farm()
	_change_state(IDLE)


func _process(_delta: float) -> void:
	match state:
		RUN:
			velocity.x = facing * speed * GameState.TILE_SIZE
		HIT:
			rotation_degrees += -facing * ROTATE_SPEED * _delta
			if GameState.is_outside(position):
				queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		if _is_farm_edge_reached():
			_change_state(IDLE)
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_farm() -> void:
	farm_points = Array(get_node(farm_path).get_points())
	assert(farm_points.size() == 2)
	farm_points.sort() # Left to right


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity
			return
		elif collision.normal.x != 0:
			_change_state(IDLE)


func _change_state(new_state) -> void:
	if state == new_state:
		return
		
	match new_state:
		IDLE:
			$Label.text = "IDLE"
			$AnimatedSprite.play("idle")
			velocity = Vector2.ZERO
		RUN:
			$Label.text = "RUN"
			$AnimatedSprite.play("run")
		HIT:
			$Label.text = "HIT"
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$AggroArea/CollisionShape2D.disabled = true
			$Timer.stop()

	state = new_state


func _think() -> void:
	_face_the_target()
	if not _is_farm_edge_reached():
		if test_move(get_transform(), Vector2(0, 4) + position + Vector2(16, 0) * facing):
			_change_state(RUN)
	$Timer.start(THINK_INTERVAL)


func _is_farm_edge_reached() -> bool:
	if not farm_path:
		return false
	
	var target = farm_points[float(facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if facing == GameState.FACING.RIGHT else distance > 0 


func _face_the_target() -> void:
	if chased_target:
		facing = sign((chased_target.position - position).x)
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		chased_target = body
		_think()


func _on_AggroArea_body_exited(body) -> void:
	if state!= HIT and body.is_in_group("player"):
		_change_state(IDLE)
		chased_target = null
		$Timer.stop()


func _on_Timer_timeout() -> void:
	_think()
