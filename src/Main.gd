extends Node

const CHAPTERS := {
	1: { "num_levels": 18 },
	2: { "num_levels": 20 },
}

export(int) var initial_chapter := 1
export(int) var initial_level := 1

var _current_level: Node


func _init() -> void:
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()


onready var _pause_menu := $Interface/PauseMenu
onready var _hud := $Interface/HUD
onready var _transition := $Transition

onready var _tracks := [
	preload("res://assets/Music/1977__rhumphries__rbh-126bpm-tabla-04.wav"),
	preload("res://assets/Music/1980__rhumphries__rbh-126bpm-tabla-09.wav"),
	preload("res://assets/Music/1981__rhumphries__rbh-126bpm-tabla-01.wav"),
	preload("res://assets/Music/1982__rhumphries__rbh-126bpm-tabla-02.wav"),
	preload("res://assets/Music/1984__rhumphries__rbh-126bpm-tabla-07.wav"),
	preload("res://assets/Music/1985__rhumphries__rbh-126bpm-tabla-08.wav"),
]

func _ready() -> void:
	open_level(initial_chapter, initial_level)


func _notification(what) -> void:
	print(what)
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		_pause_menu.call("open")


func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"):
		var tree = get_tree()
		_pause_menu.call("open" if not tree.paused else "close")
		tree.set_input_as_handled()


func open_level(chapter: int, level: int) -> void:
	_fade_out_music()
	_hud.visible = false
	
	var str_id = "Level_%d_%0*d" % [chapter, 2, level]
	var loader = ResourceLoader.load_interactive("res://src/Levels/%s.tscn" % str_id)
	
	if _current_level:
		_transition.fade_out()
		yield(_transition, "transitioned")
		remove_child(_current_level)
	
	loader.wait()
	
	_current_level = (loader.get_resource() as PackedScene).instance()
	# warning-ignore:return_value_discarded
	_current_level.connect("completed", self, "_on_level_completed")
	# warning-ignore:return_value_discarded
	_current_level.connect("defeated", self, "_on_defeated")
	add_child(_current_level)
	
	_transition.fade_in()
	_play_random_track()
	yield(_transition, "transitioned")
	_hud.visible = true	
	_current_level.create_player()


func restart_level() -> void:
	var stats = _current_level.get_info()
	open_level(stats.chapter_id, stats.level_id)


func next_level() -> void:
	var stats = _current_level.get_info()
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
	var stats = _current_level.get_info()
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


func _on_HUD_next_level() -> void:
	next_level()


func _on_HUD_restart_level() -> void:
	restart_level()


func _on_Music_finished() -> void:
	$Music.play()


func _on_level_completed() -> void:
	next_level()


func _on_defeated() -> void:
	restart_level()


func _play_random_track() -> void:
	_tracks.shuffle()
	$Music.set_stream(_tracks.front())
	_fade_in_music()
	$Music.play()


func _fade_in_music() -> void:
	$Music.volume_db = -80
	$Tween.interpolate_property($Music, "volume_db", -80, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN, 0)
	$Tween.start()


func _fade_out_music() -> void:
	$Tween.interpolate_property($Music, "volume_db", 0, -80, 1, Tween.TRANS_SINE, Tween.EASE_IN, 0)
	$Tween.start()
