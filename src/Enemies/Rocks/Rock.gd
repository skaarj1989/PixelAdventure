extends KinematicBody2D

enum {IDLE, RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(int) var facing := 1
export(float) var speed := 1.0 # Tiles/sec
# (optional) Line2D that holds exactly 2 points
export(NodePath) var patrol_path

var state
var velocity := Vector2.ZERO
var last_velocity := velocity # Before collision
var patrol_points = [] # [0] = left, [1] = right


onready var animated_sprite := $AnimatedSprite

func _ready() -> void:
	if patrol_path:
		_setup_patrol_points()
	_change_state(RUN)


func _process(_delta: float) -> void:
	if state != HIT:
		if patrol_path and _is_patrol_point_reached():
			_change_state(IDLE)
	else:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		_check_collisions()


func _on_hit() -> void: pass


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _on_Timer_timeout() -> void:
	_change_state(RUN)


func _setup_patrol_points() -> void:
	patrol_points = Array(get_node(patrol_path).get_points())
	assert(patrol_points.size() == 2)
	patrol_points.sort() # Left to right


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity # Don't stop moving on collision
		elif collision.normal.x != 0:
			_change_state(IDLE)


func _change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("idle")
			velocity.x = 0
			facing = -facing
			$Timer.start()
		RUN:
			$AnimatedSprite.play("run")
			$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
			velocity.x = facing * speed * GameState.TILE_SIZE
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			_on_hit()
		
	state = new_state


func _is_patrol_point_reached() -> bool:
	# Remaps facing to: [0, 1] = [left, right]
	var target = patrol_points[float(facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if facing == GameState.FACING.RIGHT else distance > 0 


func _get_width() -> int:
	return animated_sprite.frames.get_frame("idle", 0).get_size()


func _spawn_child(prefab, offset: Vector2) -> void:
	var child = prefab.instance()
	child.position = position + offset
	child.facing = sign(offset.x)
	child.speed = speed * 1.5
	child.patrol_path = patrol_path
	get_parent().add_child(child)
