extends KinematicBody2D

enum {IDLE, RUN, HIT, DEAD}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var speed := 1.5 # Tiles/sec
# (optional) Line2D that holds exactly 2 points
export(NodePath) var patrol_path 

var state
var is_angry := false
var velocity := Vector2.ZERO
var last_velocity := velocity
var patrol_points = [] # [0] = left, [1] = right


func _ready() -> void:
	if patrol_path:
		setup_patrol_path()
	change_state(RUN)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
	if state == RUN:
		velocity.x = facing * speed * GameState.TILE_SIZE
	
	if state == DEAD:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()
	else:
		if patrol_path and is_patrol_point_reached():
			turn_around()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	match state:
		IDLE, RUN:
			check_collisions()


func setup_patrol_path() -> void:
	patrol_points = Array(get_node(patrol_path).get_points())
	assert(patrol_points.size() == 2)
	patrol_points.sort() # Left to right


func turn_around():
	facing = -facing
	if not is_angry:
		change_state(IDLE)
	else:
		velocity.x = facing * speed * GameState.TILE_SIZE


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity
			return
		elif collision.normal.x != 0:
			turn_around()


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("idle")
			velocity = Vector2.ZERO
			$Timer.start()
		RUN:
			$AnimatedSprite.play("walk" if not is_angry else "run")
		HIT:
			$AnimatedSprite.play("hit1")
			speed *= 3.0
			is_angry = true
		DEAD:
			$AnimatedSprite.play("hit2")
			$CollisionShape2D.disabled = true
		
	state = new_state


func is_patrol_point_reached() -> bool:
	# Remaps facing to: [0, 1] = [left, right]
	var target = patrol_points[float(facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if facing == GameState.FACING.RIGHT else distance > 0 


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if not is_angry:
		change_state(HIT)
	else:
		velocity = Vector2(
			-facing,
			-5.0
		) * GameState.TILE_SIZE
		change_state(DEAD)
		GameState.camera.add_trauma(0.5)
	return true


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit1":
		change_state(RUN)


func _on_Timer_timeout() -> void:
	change_state(RUN)
