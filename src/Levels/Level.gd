extends Node2D

var chapters := {
	1: { "num_levels": 18 },
	2: { "num_levels": 20 },
}


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
	var stats = stat_current_level()
	var chapter_id = stats.chapter_id
	var current_chapter = chapters[chapter_id]
	var level_id = stats.level_id
	if level_id == current_chapter.num_levels:
		chapter_id += 1
		level_id = 1
	else:
		level_id += 1
		
	if chapter_id <= chapters.size():
		open_level(chapter_id, level_id)


func _on_HUD_prev_level():
	var stats = stat_current_level()
	var chapter_id = stats.chapter_id
	var level_id = stats.level_id
	if level_id == 1:
		chapter_id -= 1
		if chapter_id == 0:
			return
		var prev_chapter = chapters[chapter_id]
		level_id = prev_chapter.num_levels
	else:
		level_id -= 1
		
	if chapter_id > 0:
		open_level(chapter_id, level_id)


func stat_current_level():
	var fn = filename.get_file().get_basename().split("_")
	return {
		"chapter_id": fn[1].to_int(),
		"level_id": fn[2].to_int()
	}


func open_level(chapter, level) -> void:
	var str_id = "Level_%d_%0*d" % [chapter, 2, level]
	get_tree().change_scene("res://src/Levels/%s.tscn" % str_id)
