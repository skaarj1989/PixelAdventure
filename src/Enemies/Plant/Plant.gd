extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, ATTACK, HIT}
const ROTATE_SPEED := 90.0 # Degrees/sec

export(Facing) var _facing = Facing.RIGHT
export(float) var _reload_speed = 0.25 # In seconds

var _state
var _velocity := Vector2.ZERO
var _target


onready var _area_of_sight := $AreaOfSight

func _ready() -> void:
	_setup_sighting()
	$Sprite.flip_h = _facing == Facing.RIGHT
	_change_state(IDLE)


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	_velocity.y += GameState.GRAVITY * _delta
	_velocity = move_and_slide(_velocity, Vector2.UP)


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	_velocity = Vector2(
		-_facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_sighting() -> void:
	assert(_area_of_sight)
	_area_of_sight.connect("body_entered", self, "_on_Area2D_body_entered")
	_area_of_sight.connect("body_exited", self, "_on_Area2D_body_exited")


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimationPlayer.play("idle")
		ATTACK:
			$AnimationPlayer.play("attack")
		HIT:
			$AnimationPlayer.play("hit")
			$CollisionShape2D.disabled = true
			$Reload.stop()
		
	_state = new_state


func _shot() -> void:
	var bullet = GameState.shot_bullet(
			"Plant",
			position + Vector2(_facing * 20, 1),
			Vector2(_facing, 0) * GameState.TILE_SIZE * 6
	)
	get_parent().add_child(bullet)
	$Shot.play()


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	if anim_name == "attack":
		_change_state(IDLE)
		if _target:
			$Reload.start(_reload_speed)


func _on_Reload_timeout() -> void: 
	_change_state(ATTACK)


func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		_target = body
		_change_state(ATTACK)


func _on_Area2D_body_exited(body) -> void:
	if _state != HIT and body.is_in_group("player"):
		_target = null
		$Reload.stop()
