extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, FLY, HIT}
const ROTATE_SPEED := 160.0 # Degrees/sec (on death)
const eps := 1.5

export(Facing) var _facing := Facing.RIGHT
export(float) var _speed = 1.5 # Tiles/sec

var _state
var _took_off := false
var _velocity := Vector2.ZERO
var _last_velocity := _velocity
var _path = []
var _target


onready var _nav: Navigation2D = get_parent().get_node("Navigation2D")
onready var _start_position := get_global_position()

func _ready() -> void:
	_change_state(IDLE)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT
	
	match _state:
		FLY:
			_update_path()
		HIT:
			rotation_degrees += -_facing * ROTATE_SPEED * _delta
			if GameState.is_outside(position):
				queue_free()


func _physics_process(_delta: float) -> void:
	if _state != HIT:
		if _took_off and _path.size() > 1:
			var distance = _path[1] - get_global_position()
			var direction = distance.normalized() # Direction of movement
			_facing = sign(direction.x)
			if distance.length() > eps or _path.size() > 2:
				_velocity = direction * _speed * GameState.TILE_SIZE
			else:
				_velocity = Vector2.ZERO
				_change_state(IDLE)
	else:
		_velocity.y += GameState.GRAVITY * _delta
	
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


func _update_path() -> void:
	var from = get_global_position()
	var to = _start_position
	if _target != null:
		to = _target.get_global_position()
	_path = _nav.get_simple_path(from, to, true)


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			if collider.is_vulnerable_to(self):
				collider.take_damage(_last_velocity)
				_target = null
			_velocity = _last_velocity


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("ceiling_in" if _state == FLY else "idle")
		FLY:
			$AnimatedSprite.play("ceiling_out")
			_update_path()
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$AggroArea/CollisionShape2D.disabled = true
		
	_state = new_state


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "ceiling_out":
		$AnimatedSprite.play("flying")
		_took_off = true
	if $AnimatedSprite.animation == "ceiling_in":
		$AnimatedSprite.play("idle")
		_took_off = false


func _on_AggroArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		_target = body
		_change_state(FLY)


func _on_AggroArea_body_exited(body) -> void:
	if body == _target:
		_target = null
