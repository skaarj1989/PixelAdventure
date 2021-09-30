extends KinematicBody2D

enum {IDLE, FLY, HIT}
const ROTATE_SPEED := 160.0 # Degrees/sec (on death)
const eps = 1.5

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var speed := 1.5 # Tiles/sec

var state
var took_off := false
var velocity := Vector2.ZERO
var last_velocity := velocity
var path = []
var target


onready var nav: Navigation2D = get_parent().get_node("Navigation2D")
onready var start_position := get_global_position()

func _ready() -> void:
	change_state(IDLE)


func update_path() -> void:
	var from = get_global_position()
	var to = start_position
	if target != null:
		to = target.get_global_position()
	path = nav.get_simple_path(from, to, true)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
	
	match state:
		FLY:
			update_path()
		HIT:
			rotation_degrees += -facing * ROTATE_SPEED * _delta
			if GameState.is_outside(position):
				queue_free()


func _physics_process(_delta: float) -> void:
	if state != HIT:
		if took_off and path.size() > 1:
			var distance = path[1] - get_global_position()
			var direction = distance.normalized() # Direction of movement
			facing = sign(direction.x)
			if distance.length() > eps or path.size() > 2:
				velocity = direction * speed * GameState.TILE_SIZE
			else:
				velocity = Vector2.ZERO
				change_state(IDLE)
	else:
		velocity.y += GameState.GRAVITY * _delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		check_collisions()


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			if collider.is_vulnerable_to(self):
				collider.take_damage(last_velocity)
				target = null
			velocity = last_velocity


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimatedSprite.play("ceiling_in" if state == FLY else "idle")
		FLY:
			$AnimatedSprite.play("ceiling_out")
			update_path()
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$AggroArea/CollisionShape2D.disabled = true
		
	state = new_state


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _on_AggroArea_body_entered(body):
	if body.is_in_group("player"):
		target = body
		change_state(FLY)


func _on_AggroArea_body_exited(_body):
	if _body == target:
		target = null


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "ceiling_out":
		$AnimatedSprite.play("flying")
		took_off = true
	if $AnimatedSprite.animation == "ceiling_in":
		$AnimatedSprite.play("idle")
		took_off = false
