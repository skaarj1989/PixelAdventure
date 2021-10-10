extends CanvasLayer

signal transitioned

const DELAY := 0.05

onready var _columns = [
	$HBoxContainer/Column,
	$HBoxContainer/Column2,
	$HBoxContainer/Column3,
	$HBoxContainer/Column4,
	$HBoxContainer/Column5,
	$HBoxContainer/Column6,
]


# Invisible -> Visible (Game)
func fade_in() -> void:
	for c in _columns:
		c.animation_player.play("fade_in")
		c.animation_player.playback_speed = 0.1
	
	for c in _columns:
		c.animation_player.playback_speed = 1.0
		yield(get_tree().create_timer(DELAY), "timeout")
	
	yield(_columns.back().animation_player, "animation_finished")
	emit_signal("transitioned")


# Blackouts: (Game) Visible -> Invisible
func fade_out() -> void:
	for c in _columns:
		c.animation_player.play("fade_out")
		c.animation_player.playback_speed = 0.1
	
	for c in _columns:
		c.animation_player.playback_speed = 1.0
		yield(get_tree().create_timer(DELAY), "timeout")
	
	yield(_columns.back().animation_player, "animation_finished")
	emit_signal("transitioned")
