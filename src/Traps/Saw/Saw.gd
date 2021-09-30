extends KinematicBody2D

enum {ON, OFF}

export(float) var speed := 1.0 # Tiles/sec
export(NodePath) var patrol_path # (mandatory) Path2D

var state
var velocity := Vector2.ZERO
var last_velocity := velocity
var patrol_points = []
var patrol_index := -1


func _ready() -> void:
	setup_patrol_path()
	change_state(ON)


func _physics_process(_delta: float) -> void:
	if state == ON:
		var target = patrol_points[patrol_index]
		if position.distance_to(target) < 4:
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
			target = patrol_points[patrol_index]
			velocity = (target - position).normalized() * speed * GameState.TILE_SIZE
	
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	check_collisions()


func setup_patrol_path() -> void:
	assert(patrol_path)
	patrol_path = get_node(patrol_path) as Path2D
	patrol_points = patrol_path.curve.get_baked_points()
	var closest_point = GameState.get_closest_point(patrol_points, position)
	patrol_index = Array(patrol_points).find(closest_point)


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity # Don't stop movement on collision
			return


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		ON:
			$AnimatedSprite.play("on")
		OFF:
			$AnimationPlayer.play("off")
	
	state = new_state
