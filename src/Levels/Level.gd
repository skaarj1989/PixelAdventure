extends Node2D

signal completed
signal defeated

var _player: Player = null


onready var _player_prefab := preload("res://src/Player/Player.tscn")
onready	var _fruit_prefab := preload("res://src/Items/Fruits/Fruit.tscn")
onready var _block_prefab := preload("res://src/Traps/Blocks/Block.tscn")
onready var _test_play: bool = get_parent() == get_tree().get_root() # Playing a scene from the editor
onready var _num_fruits: int = $Collectibles.get_used_cells().size()

func _ready() -> void:
	_spawn_collectibles()
	_spawn_blocks()
	if _test_play:
		create_player()
		# warning-ignore:return_value_discarded
		_player.connect("dead", self, "create_player") # Just respawn


func get_info():
	var array = filename.get_file().get_basename().split("_")
	return {
		"chapter_id": array[1].to_int(),
		"level_id": array[2].to_int()
	}


func create_player():
	_player = _player_prefab.instance()
	# warning-ignore:return_value_discarded
	_player.connect("hurt", $Death, "play")
	# warning-ignore:return_value_discarded
	_player.connect("dead", self, "_on_player_death")
	add_child(_player)
	_player.spawn($SpawnPoint.position)


func _on_player_death() -> void:
	emit_signal("defeated")


func _spawn_object(obj, position: Vector2):
	obj.position = position
	add_child(obj)
	return obj


func _spawn_collectibles() -> void:
	$Collectibles.hide()
	var offset = $Collectibles.cell_size
	for cell in $Collectibles.get_used_cells():
		var id = $Collectibles.get_cellv(cell)
		var type = $Collectibles.tile_set.tile_get_name(id)
		_spawn_fruit(type.to_lower(), $Collectibles.map_to_world(cell) + offset)


func _spawn_fruit(type: String, position: Vector2):
	var fruit = _fruit_prefab.instance()
	fruit.type = type
	if not _test_play:
		fruit.connect("collected", self, "_on_fruit_collected")
	return _spawn_object(fruit, position)


func _on_fruit_collected() -> void:
	_num_fruits -= 1
	if _num_fruits == 0:
		_player.state_machine.transition_to("Disappear")
		yield(get_tree().create_timer(0.5), "timeout")
		emit_signal("completed")


func _spawn_blocks() -> void:
	$Blocks.hide()
	var offset = $Blocks.cell_size * 0.5
	for cell in $Blocks.get_used_cells():
		var obj = _block_prefab.instance()
		obj = _spawn_object(obj, $Blocks.map_to_world(cell) + offset)
