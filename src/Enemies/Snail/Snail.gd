extends KinematicBody2D

enum {IDLE, WALK, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(int) var facing := 1
export(float) var speed := 0.5 # Tiles/sec

var state
var velocity := Vector2.ZERO
var last_velocity := velocity # Before collision
var patrol_points = [] # [0] = left, [1] = right


onready var shell_prefab := preload("Shell.tscn")

func _ready() -> void:
	_change_state(WALK)


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


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
			$Timer.start()
		WALK:
			$AnimatedSprite.play("walk")
			$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
			velocity.x = facing * speed * GameState.TILE_SIZE
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			yield($AnimatedSprite, "animation_finished")
			_leave_shell()
		
	state = new_state


func _leave_shell() -> void:
	$AnimatedSprite.play("naked")
	var shell = shell_prefab.instance()
	shell.position = position
	shell.facing = facing
	get_parent().add_child(shell)


func _on_Timer_timeout() -> void:
	facing = -facing
	_change_state(WALK)
