extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, RUN, HIT, HIT_WALL}
const ROTATE_SPEED = 80.0 # Degrees/sec (on death)

export(Facing) var _facing = Facing.LEFT
export(float) var _speed = 8.0 # Tiles/sec

var _state
var _velocity := Vector2.ZERO
var _last_velocity := _velocity
var _target


onready var _aggro_area := $AggroArea

func _ready() -> void:
	_setup_aggro_area()
	_change_state(IDLE)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT
	if _state == HIT:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	if _state == RUN:
		_velocity.x = _facing * _speed * GameState.TILE_SIZE
	
	_velocity.y += GameState.GRAVITY * _delta
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


func _setup_aggro_area() -> void:
	assert(_aggro_area)
	_aggro_area.connect("body_entered", self, "_on_AggroArea_body_entered")
	_aggro_area.connect("body_exited", self, "_on_AggroArea_body_exited")


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity
			return
		elif collision.normal.x != 0:
			_velocity = Vector2(
				-_facing,
				-10.0
			) * GameState.TILE_SIZE
			GameState.camera.add_trauma(0.8)
			_change_state(HIT_WALL)
			return
		elif collision.normal.y == -1 and _state == HIT_WALL:
			_change_state(IDLE)
			return


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("idle")
			_velocity = Vector2.ZERO
		RUN:
			_facing = sign((_target.position - position).x)
			$AnimatedSprite.play("run")
		HIT_WALL:
			$AnimatedSprite.play("hit_wall")
		HIT:
			$Label.text = "HIT"
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			_aggro_area.get_node("CollisionShape2D").disabled = true
			$Recover.stop()
		
	_state = new_state


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit_wall":
		$Recover.start()


func _on_Recover_timeout():
	_change_state(RUN if _target != null else IDLE)


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		_target = body
		if _state != HIT_WALL:
			_change_state(RUN)


func _on_AggroArea_body_exited(body) -> void:
	if _target == body:
		_target = null
