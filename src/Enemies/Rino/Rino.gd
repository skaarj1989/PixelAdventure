extends KinematicBody2D

enum {IDLE, RUN, HIT, HIT_WALL}
const ROTATE_SPEED = 80.0 # Degrees/sec (on death)

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var speed := 8.0 # Tiles/sec
export(NodePath) var area_of_sight # (mandatory) Area2D

var state
var velocity := Vector2.ZERO
var last_velocity := velocity
var target

func _ready() -> void:
	setup_sighting()
	change_state(IDLE)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
	if state == HIT:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	if state == RUN:
		velocity.x = facing * speed * GameState.TILE_SIZE
	
	velocity.y += GameState.GRAVITY * _delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		check_collisions()


func setup_sighting() -> void:
	assert(area_of_sight)
	area_of_sight = get_node(area_of_sight) as Area2D
	area_of_sight.connect("body_entered", self, "_on_AggroArea_body_entered")
	area_of_sight.connect("body_exited", self, "_on_AggroArea_body_exited")


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity
			return
		elif collision.normal.x != 0:
			velocity = Vector2(
				-facing,
				-10.0
			) * GameState.TILE_SIZE
			GameState.camera.add_trauma(0.8)
			change_state(HIT_WALL)
			return
		elif collision.normal.y == -1 and state == HIT_WALL:
			change_state(IDLE)
			return


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("idle")
			velocity = Vector2.ZERO
		RUN:
			facing = sign((target.position - position).x)
			$AnimatedSprite.play("run")
		HIT_WALL:
			$AnimatedSprite.play("hit_wall")
		HIT:
			$Label.text = "HIT"
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			area_of_sight.get_node("CollisionShape2D").disabled = true
			$Recover.stop()
		
	state = new_state


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		target = body
		if state != HIT_WALL:
			change_state(RUN)


func _on_AggroArea_body_exited(body) -> void:
	if target == body:
		target = null


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit_wall":
		$Recover.start()


func _on_Recover_timeout():
	change_state(RUN if target != null else IDLE)
