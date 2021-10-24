extends Control


func _on_MoveLeft_button_down() -> void:
	Input.action_press("move_left")


func _on_MoveLeft_button_up() -> void:
	Input.action_release("move_left")


func _on_MoveRight_button_down() -> void:
	Input.action_press("move_right")


func _on_MoveRight_button_up() -> void:
	Input.action_release("move_right")


func _on_Jump_pressed() -> void:
	Input.action_press("jump")


func _on_Descent_pressed() -> void:
	Input.action_press("descent")
