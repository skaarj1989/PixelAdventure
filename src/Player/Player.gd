class_name Player
extends KinematicBody2D

signal hurt
signal dead

const ACCELERATION := 0.5 # [0..1]
export(float) var speed := 4.5 # Tiles/sec

var facing = GameState.FACING.RIGHT
var velocity := Vector2.ZERO
var snap := Vector2.ZERO
var surface_type = GameState.SURFACE_TYPE.DEFAULT
var last_velocity := velocity
var input_direction_x: float
var can_jump := true


onready var state_machine := $StateMachine
onready var collision_shape := $CollisionShape2D
onready var raycast := $RayCast2D
onready var sprite := $Sprite
onready var animation_player := $AnimationPlayer
onready var animated_sprite := $AnimatedSprite

func _ready() -> void:
	$Sprite.texture = _get_random_skin()
	$Sprite.visible = false


func _process(_delta: float) -> void:
	match $StateMachine.state.name:
		"Appear", "Disappear":
			return
	
	#$Label.text = $StateMachine.state.name
	#$Label.text = String(facing)
	#$Label.text = "[%.1f, %.1f]" % [velocity.x, velocity.y]
	#$Label.text = GameState.SURFACE_TYPE.keys()[surface_type]
	$Label.text = String(snap)

	$Sprite.flip_h = facing == GameState.FACING.LEFT
	
	if $StateMachine.state.name != "Hit":
		input_direction_x = _get_input_direction()
		if input_direction_x != 0:
			facing = sign(input_direction_x)
	else:
		if GameState.is_outside(position):
			queue_free()
			emit_signal("dead")
	
	if Input.is_key_pressed(KEY_S):
		GameState.camera.add_trauma(0.05)


func _physics_process(_delta: float) -> void:
	match $StateMachine.state.name:
		"Appear", "Disappear":
			return
	
	var friction := _get_friction()
	if $StateMachine.state.name != "Hit":
		if input_direction_x != 0:
			var max_velocity = input_direction_x * speed * GameState.TILE_SIZE
			velocity.x = lerp(velocity.x, max_velocity, (1.0 - friction) * ACCELERATION)
		else:
			velocity.x = lerp(velocity.x, 0, friction)
	
	if $StateMachine.state.name == "WallJump":
		velocity.y = GameState.TILE_SIZE * (1.0 - friction)
	else:
		velocity.y += GameState.GRAVITY * _delta

	last_velocity = velocity
	#velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI / 4, true)
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, false, 4, PI / 4, true)
	if $StateMachine.state.name != "Hit":
		_check_collisions()


func spawn(_position: Vector2) -> void:
	position = _position
	facing = 1 if position.x < GameState.GAME_AREA.x * 0.5 else -1
	$StateMachine.transition_to("Appear")


func _get_random_skin() -> Texture:
	var skins = ["MaskDude", "NinjaFrog", "PinkMan", "VirtualGuy"]
	var skin = GameState.pick_random_item(skins)
	skin = load("res://assets/MainCharacters/%s/spritesheet.png" % skin)
	return skin


func _get_input_direction() -> float:
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func _get_friction() -> float:
	match surface_type:
		GameState.SURFACE_TYPE.SAND:
			return 0.5
		GameState.SURFACE_TYPE.MUD:
			return 1.0
		GameState.SURFACE_TYPE.ICE:
			return 0.0
	return 0.25 # SURFACE_TYPE.DEFAULT


func _check_collisions() -> void:
	var num_collisions = get_slide_count()
	if num_collisions == 0:
		surface_type = GameState.SURFACE_TYPE.DEFAULT
	else:
		for idx in range(num_collisions):
			var collision = get_slide_collision(idx)
			var collider = collision.collider
			if collider.name == "Spike":
				take_damage()
				return
			
			# NOTE: using 'match' instead of 'if' issued an hard to find bug!
			# Order of groups in array returned by '.get_groups()' varies between calls
			# hence using an open-ended array pattern: ["enemy", ..] will result in
			# undetected collision in cases when the "enemy" group is not the first element
			# in the array, like: ["idle_process", "enemy", "physics_process"]
			if collider.is_in_group("terrain"):
				surface_type = GameState.SURFACE_TYPE.DEFAULT
			elif collider.is_in_group("sand"):
				surface_type = GameState.SURFACE_TYPE.SAND
				velocity.x *= (1.0 - _get_friction())
			elif collider.is_in_group("mud"):
				surface_type = GameState.SURFACE_TYPE.MUD
				velocity.x *= (1.0 - _get_friction())
			elif collider.is_in_group("ice"):
				surface_type = GameState.SURFACE_TYPE.ICE
			elif collider.is_in_group("projectile"):
				take_damage(collider.velocity)
				return
			elif collider.is_in_group("trap"):
				take_damage(collision.collider_velocity)
				return
			elif collider.is_in_group("enemy"):
				if can_deal_damage(collider):
					if collider.take_damage(last_velocity):
						$Punch.play()
						bounce_up(8.0)
				else:
					take_damage()
				return


func get_feet_position() -> Vector2:
	return position + $CollisionShape2D.shape.extents


func can_deal_damage(enemy_collider: Object) -> bool:
	return get_feet_position().y < enemy_collider.position.y


func is_vulnerable_to(enemy_collider: Object) -> bool:
	return enemy_collider.position.y < get_feet_position().y


func is_idle() -> bool:
	return input_direction_x == 0 or is_equal_approx(velocity.x, 0.0) 


func is_falling() -> bool:
	return velocity.y > 0


func bounce_up(power: float = 1.0) -> void:
	can_jump = true
	$StateMachine.transition_to("Jump", {"power": power})


func spawn_dust() -> void:
	add_child(GameState.spawn_dust(Vector2(0, 16), Vector2(0, -10)))


func take_damage(_from: Vector2 = Vector2.ZERO) -> void:
	if $StateMachine.state.name == "Hit":
		return
	
	$StateMachine.transition_to("Hit")
	if _from != Vector2.ZERO:
		velocity = _from
	else:
		# Stepped on an enemy
		velocity.x *= -facing
	
	velocity.y = -5 * GameState.TILE_SIZE
	$CollisionShape2D.set_deferred("disabled", true)
	GameState.camera.add_trauma(0.5)
	emit_signal("hurt")


#func disable_body() -> void:
#	$CollisionShape2D.disabled = true
