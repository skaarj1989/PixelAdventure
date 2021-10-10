extends MarginContainer

signal prev_level
signal next_level
signal restart_level


func _on_PrevLevelButton_pressed() -> void:
	emit_signal("prev_level")


func _on_NextLevelButton_pressed() -> void:
	emit_signal("next_level")


func _on_RestartLevelButton_pressed() -> void:
	emit_signal("restart_level")
