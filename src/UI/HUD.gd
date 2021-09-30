extends MarginContainer

signal prev_level
signal next_level
signal restart_level


func _on_Prev_pressed() -> void: emit_signal("prev_level")
func _on_Next_pressed() -> void: emit_signal("next_level")
func _on_Restart_pressed() -> void: emit_signal("restart_level")
