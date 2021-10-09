extends Control


onready var _in_audio := preload("res://assets/SFX/UI/sfx_sounds_pause4_in.wav")
onready var _out_audio := preload("res://assets/SFX/UI/sfx_sounds_pause4_out.wav")
onready var _resume_button := $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	hide()


func open() -> void:
	get_tree().paused = true
	$Audio.set_stream(_in_audio)
	$Audio.play()
	_resume_button.grab_focus()
	show()


func close() -> void:
	get_tree().paused = false
	$Audio.set_stream(_out_audio)
	$Audio.play()
	hide()


func _on_Resume_pressed() -> void:
	close()


func _on_Quit_pressed() -> void:
	get_tree().quit()
