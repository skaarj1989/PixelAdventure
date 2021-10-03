extends Node2D


onready var player_prefab := preload("res://src/Player/Player.tscn")
onready	var fruit_prefab := preload("res://src/Items/Fruits/Fruit.tscn")
onready var block_prefab := preload("res://src/Traps/Blocks/Block.tscn")

func _ready() -> void:
	spawn_collectibles()
	spawn_blocks()
	
	# Play scene from the editor 
	if get_parent() == get_tree().get_root():
		create_player()


func get_info():
	var array = filename.get_file().get_basename().split("_")
	return {
		"chapter_id": array[1].to_int(),
		"level_id": array[2].to_int()
	}


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
	player.connect("dead", self, "create_player")
	player.spawn($SpawnPoint.position)
