class_name StateMachine
extends Node

signal transitioned(state_name)

export(NodePath) var initial_state := NodePath()


onready var state: State = get_node(initial_state)

func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		child.state_machine = self
	state.enter()


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		push_warning("State: %s not found!" % target_state_name)
		return

	var next_state = get_node(target_state_name)
	#print("Enter: ", target_state_name)

	state.exit()
	state = next_state
	state.enter(msg)
	emit_signal("transitioned", state.name)
