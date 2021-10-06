extends Control

onready var _resume_button := $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	hide()


func open() -> void:
	get_tree().paused = true
	_resume_button.grab_focus()
	show()


func close() -> void:
	get_tree().paused = false
	hide()


func _on_Resume_pressed() -> void:
	close()


func _on_Quit_pressed() -> void:
	get_tree().quit()
