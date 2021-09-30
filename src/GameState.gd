extends Node

const TILE_SIZE := 32 # In pixels
const GAME_AREA := Vector2(512, 256) # in pixels
const GRAVITY := 1000

enum FACING {LEFT = -1, RIGHT = 1}
enum SURFACE_TYPE {DEFAULT, SAND, MUD, ICE}
#enum FRUITS {APPLE, BANANAS, CHERRIES, KIWI, MELON, ORANGE, PINEAPPLE, STRAWBERRY}

var camera: Camera2D = null

onready var dust_prefab := preload("res://src/FX/Dust.tscn")
onready var splash_prefab := preload("res://src/FX/Splash.tscn")
onready var bullet_prefab = preload("res://src/Enemies/Bullet.tscn")


func spawn_dust(position: Vector2 = Vector2.ZERO, gravity := Vector2(0, -98)):
	var dust = dust_prefab.instance()
	dust.position = position
	dust.process_material.gravity = Vector3(gravity.x, gravity.y, 0.0)
	dust.process_material.direction = Vector3(sign(gravity.x), sign(gravity.y), 0.0)
	return dust


func spawn_splash(surface_type, position: Vector2 = Vector2.ZERO):
	var splash = splash_prefab.instance()
	splash.position = position
	match surface_type:
		SURFACE_TYPE.SAND:
			splash.texture = load("res://assets/Traps/Sand Mud Ice/sand_particle.png")
		SURFACE_TYPE.MUD:
			splash.texture = load("res://assets/Traps/Sand Mud Ice/mud_particle.png")
		SURFACE_TYPE.ICE:
			splash.texture = load("res://assets/Traps/Sand Mud Ice/ice_particle.png")
		_: assert(false)
	#get_tree().get_root().add_child(splash)
	return splash


func shot_bullet(shooter: String, start_position: Vector2, velocity: Vector2):
	var bullet = bullet_prefab.instance()
	bullet.shooter_name = shooter
	bullet.position = start_position
	bullet.velocity = velocity
	get_tree().get_root().add_child(bullet)
	return bullet


func is_outside(position: Vector2) -> bool:
	return position.y > GAME_AREA.y or position.x > GAME_AREA.x


func pick_random_item(items: Array):
	randomize()
	var idx = randi() % items.size()
	return items[idx]


func get_closest_point(array : Array, to_point : Vector2) -> Vector2:
	var shortest_dist := 0.0
	var closest_point = null
	for pt in array:
		var dst = pt.distance_to(to_point)
		if closest_point == null or dst < shortest_dist:
			shortest_dist = dst
			closest_point = pt

	return closest_point
