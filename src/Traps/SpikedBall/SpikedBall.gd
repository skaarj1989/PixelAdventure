extends KinematicBody2D

# https://www.youtube.com/watch?v=J1ClXGZIh00

export(NodePath) var attachment_point
export(float) var gravity = 9.8
export(float) var damping = 1.0
export(float) var angular_velocity = 0.15

var angle := 0.0
var angular_acceleration = 0.0

onready var attachment_position := (get_node(attachment_point) as Position2D).get_global_position()
onready var chain := preload("res://assets/Traps/SpikedBall/chain.png")
onready var chain_size := chain.get_size()
onready var chain_offset := chain_size * 0.5
onready var chain_margin := chain_offset * 0.5

func _ready():
	#angle = Vector2.ZERO.angle_to(get_global_position() - attachment_position) - deg2rad(-90)
	pass

func _process(_delta: float) -> void:
	update()


func _physics_process(_delta: float) -> void:
	var arm_length = get_arm_length()
	angular_acceleration = ((-gravity * _delta) / arm_length) * sin(angle)
	angular_velocity += angular_acceleration
	angular_velocity *= damping
	angle += angular_velocity
	global_position = attachment_position + Vector2(
		arm_length * sin(angle),
		arm_length * cos(angle)
	)


func _draw() -> void:
	var dir_to_ball = attachment_position.direction_to(get_global_position())
	var steps = ceil(get_arm_length()) / (chain_size + chain_margin).x
	for i in range(1, steps ):
		var link_pos = i * dir_to_ball * (chain_size + chain_margin * 1.5)
		draw_texture(chain, to_local(attachment_position + link_pos - chain_offset))


func get_arm_length() -> float:
	return get_global_position().distance_to(attachment_position)
