extends Node

const CHAPTERS := {
	1: { "num_levels": 18 },
	2: { "num_levels": 20 },
}

export(int) var initial_chapter := 1
export(int) var initial_level := 1

var current_level: Node


func _init() -> void:
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()


onready var _pause_menu := $Interface/PauseMenu
onready var _hud := $Interface/HUD
onready var _transition := $Transition

func _ready() -> void:
	open_level(initial_chapter, initial_level)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"):
		var tree = get_tree()
		_pause_menu.call("open" if not tree.paused else "close")
		tree.set_input_as_handled()


func _on_HUD_restart_level() -> void:
	var stats = current_level.get_info()
	open_level(stats.chapter_id, stats.level_id)


func _on_HUD_next_level() -> void:
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


func open_level(chapter: int, level: int) -> void:
	_hud.visible = false
	
	var str_id = "Level_%d_%0*d" % [chapter, 2, level]
	var loader = ResourceLoader.load_interactive("res://src/Levels/%s.tscn" % str_id)
	
	if current_level:
		_transition.fade_out()
		yield(_transition, "transitioned")
		remove_child(current_level)
	
	loader.wait()
	
	current_level = (loader.get_resource() as PackedScene).instance()
	add_child(current_level)
	
	_transition.fade_in()
	yield(_transition, "transitioned")
	_hud.visible = true	
	current_level.create_player()
