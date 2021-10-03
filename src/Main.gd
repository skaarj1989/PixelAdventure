extends Node

const CHAPTERS := {
	1: { "num_levels": 18 },
	2: { "num_levels": 20 },
}

export(int) var initial_chapter := 1
export(int) var initial_level := 1

var current_level: Node
var locked_hud := false


func _ready() -> void:
	open_level(initial_chapter, initial_level)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func _on_HUD_restart_level() -> void:
	if locked_hud: return
	
	var stats = current_level.get_info()
	open_level(stats.chapter_id, stats.level_id)


func _on_HUD_next_level() -> void:
	if locked_hud: return
	
	var stats = current_level.get_info()
	var chapter_id = stats.chapter_id
	var current_chapter = CHAPTERS[chapter_id]
	var level_id = stats.level_id
	if level_id == current_chapter.num_levels:
		chapter_id += 1
		level_id = 1
	else:
		level_id += 1
		
	if chapter_id <= CHAPTERS.size():
		open_level(chapter_id, level_id)


func _on_HUD_prev_level() -> void:
	if locked_hud: return
	
	var stats = current_level.get_info()
	var chapter_id = stats.chapter_id
	var level_id = stats.level_id
	if level_id == 1:
		chapter_id -= 1
		if chapter_id == 0:
			return
		var prev_chapter = CHAPTERS[chapter_id]
		level_id = prev_chapter.num_levels
	else:
		level_id -= 1
		
	if chapter_id > 0:
		open_level(chapter_id, level_id)


func _on_Transition_transitioned() -> void:
	locked_hud = false


func open_level(chapter: int, level: int) -> void:
	locked_hud = true
	
	var str_id = "Level_%d_%0*d" % [chapter, 2, level]
	var loader = ResourceLoader.load_interactive("res://src/Levels/%s.tscn" % str_id)
	
	if current_level:
		$Transition.get_node("HBoxContainer").show()
		$Transition.fade_out()
		yield($Transition, "transitioned")
		remove_child(current_level)
	
	loader.wait()
	
	current_level = (loader.get_resource() as PackedScene).instance()
	add_child(current_level)
	
	$Transition.fade_in()
	yield($Transition, "transitioned")
	current_level.create_player()
