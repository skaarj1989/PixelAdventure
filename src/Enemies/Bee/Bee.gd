extends KinematicBody2D

enum {IDLE, ATTACK, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(float) var speed := 2.0 # Tiles/sec
export(NodePath) var patrol_path # (mandatory) Path2D

var state
var velocity := Vector2.ZERO
var last_velocity := velocity
var patrol_points = []
var patrol_index := -1


func _ready() -> void:
	_setup_patrol_path()
	_change_state(IDLE)


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	if state != HIT:
		var target = patrol_points[patrol_index]
		var d = position.distance_to(target)
		if d < 16:
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
			target = patrol_points[patrol_index]
			velocity = (target - position).normalized() * speed * GameState.TILE_SIZE
	else:
		velocity.y += GameState.GRAVITY * delta
	
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-sign(velocity.x),
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_patrol_path() -> void:
	assert(patrol_path)
	patrol_points = get_node(patrol_path).curve.get_baked_points()
	var closest_point = GameState.get_closest_point(patrol_points, position)
	patrol_index = Array(patrol_points).find(closest_point)


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity # Don't stop movement on collision
			return


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
	if state == new_state:
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
		
	state = new_state


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		_change_state(ATTACK)


func _on_AggroArea_body_exited(body) -> void:
	if state != HIT and body.is_in_group("player"):
		_change_state(IDLE)
