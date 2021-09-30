extends Node2D

onready var player_prefab := preload("res://src/Player/Player.tscn")
onready	var fruit_prefab := preload("res://src/Items/Fruits/Fruit.tscn")
onready var block_prefab := preload("res://src/Traps/Blocks/Block.tscn")

func _ready() -> void:
	spawn_collectibles()
	spawn_blocks()


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func spawn_collectibles() -> void:
	$Collectibles.hide()
	var offset = $Collectibles.cell_size
	for cell in $Collectibles.get_used_cells():
		var id = $Collectibles.get_cellv(cell)
		var type = $Collectibles.tile_set.tile_get_name(id)
		spawn_fruit(type.to_lower(), $Collectibles.map_to_world(cell) + offset)


func spawn_fruit(type: String, position: Vector2):
	var fruit = fruit_prefab.instance()
	fruit.type = type
	return spawn_object(fruit, position)


func spawn_blocks() -> void:
	$Blocks.hide()
	var offset = $Blocks.cell_size * 0.5
	for cell in $Blocks.get_used_cells():
		var obj = block_prefab.instance()
		obj = spawn_object(obj, $Blocks.map_to_world(cell) + offset)


func spawn_object(obj, position: Vector2):
	obj.position = position
	add_child(obj)
	return obj


func create_player() -> void:
	var player = player_prefab.instance()
	add_child(player)
	player.connect("dead", $Timer, "start")
	player.spawn($SpawnPoint.position)


func _on_Timer_timeout() -> void:
	create_player()


func _on_HUD_restart_level() -> void:
	get_tree().reload_current_scene()


func _on_HUD_next_level():
	pass


func _on_HUD_prev_level():
	pass
