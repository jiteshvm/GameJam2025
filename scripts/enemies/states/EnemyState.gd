@abstract class_name EnemyState
extends RefCounted

var _state_name: String = ""
var _enemy: Enemy = null
var _blackboard: EnemyStateBlackboard = null
var _current_sub_state: EnemyState = null
var _default_sub_state: EnemyState = null
var _parent_state: EnemyState = null

var _sub_states: Array[EnemyState] = []
var _state_transitions: Dictionary[StateTransitionTrigger, EnemyState] = {}

func setup_init(state_name: String, enemy: Enemy) -> void:
	_state_name = state_name
	_enemy = enemy
	_blackboard = enemy.get_blackboard()

func setup_add_sub_state(sub_state: EnemyState) -> void:
	if _sub_states.size() == 0:
		_default_sub_state = sub_state

	sub_state.internal_setup_set_parent_state(self)

	# Ensure the state does not already exist.
	for existing_sub_state: EnemyState in _sub_states:
		if existing_sub_state == sub_state:
			push_error("Sub state %s already exists" % sub_state)
			return
	_sub_states.append(sub_state)

func internal_setup_set_parent_state(parent_state: EnemyState) -> void:
	_parent_state = parent_state

func setup_add_state_transition(origin_state: EnemyState, target_state: EnemyState, trigger: StateTransitionTrigger) -> void:
	if !_sub_states.has(origin_state):
		var origin_state_type_string: String = _get_custom_type_string(origin_state)
		push_error("Origin state %s not found" % origin_state_type_string)
		return
	if !_sub_states.has(target_state):
		var target_state_type_string: String = _get_custom_type_string(target_state)
		push_error("Target state %s not found" % target_state_type_string)
		return
	origin_state.internal_setup_add_state_transition(target_state, trigger)

func internal_setup_add_state_transition(target_state: EnemyState, trigger: StateTransitionTrigger) -> void:
	# Ensure there are no duplicate triggers.
	for existing_trigger: StateTransitionTrigger in _state_transitions.keys():
		if existing_trigger == trigger:
			push_error("State transition trigger %s already exists" % trigger)
			return
	_state_transitions[trigger] = target_state

func enter_as_state_machine() -> void:
	on_enter_state()
	if _current_sub_state == null and _default_sub_state != null:
		_current_sub_state = _default_sub_state
	
	if _current_sub_state != null:
		_current_sub_state.enter_as_state_machine()

func exit_as_state_machine() -> void:
	if _current_sub_state != null:
		_current_sub_state.exit_as_state_machine()
	on_exit_state()

func process_as_state_machine(delta: float) -> void:
	on_process_state(delta)
	if _current_sub_state != null:
		_current_sub_state.process_as_state_machine(delta)

func physics_process_as_state_machine(delta: float) -> void:
	on_physics_process_state(delta)
	if _current_sub_state != null:
		_current_sub_state.physics_process_as_state_machine(delta)

## Pass up the trigger until it is consumed.
## Returns true if the trigger resulted in a state transition.
func activate_trigger(trigger: StateTransitionTrigger) -> bool:
	var current_state: EnemyState = self
	while current_state != null:
		var target_state: EnemyState = current_state.internal_get_state_transition(trigger)
		if target_state == null:
			current_state = current_state.internal_get_parent_state()
			continue
		current_state.internal_get_parent_state().internal_change_sub_state(target_state)
		return true
	return false

func force_change_sub_state(new_state: EnemyState) -> void:
	internal_change_sub_state(new_state)

func internal_get_parent_state() -> EnemyState:
	return _parent_state

func internal_get_state_transition(trigger: StateTransitionTrigger) -> EnemyState:
	var found_trigger: StateTransitionTrigger = null
	for existing_trigger: StateTransitionTrigger in _state_transitions.keys():
		var existing_trigger_type_string: String = _get_custom_type_string(existing_trigger)
		var trigger_type_string: String = _get_custom_type_string(trigger)
		if existing_trigger_type_string == trigger_type_string:
			found_trigger = existing_trigger
			break
	if found_trigger == null:
		return null
	return _state_transitions[found_trigger]

func internal_get_current_sub_state() -> EnemyState:
	return _current_sub_state

func internal_change_sub_state(new_state: EnemyState) -> void:
	if _current_sub_state != null:
		_current_sub_state.exit_as_state_machine()
	_current_sub_state = new_state
	new_state.enter_as_state_machine()

func get_blackboard() -> EnemyStateBlackboard:
	return _blackboard

func get_state_name() -> String:
	return _state_name

@abstract func on_enter_state() -> void

@abstract func on_exit_state() -> void

@abstract func on_process_state(delta: float) -> void

@abstract func on_physics_process_state(delta: float) -> void

@abstract class StateTransitionTrigger:
	pass

func _get_custom_type_string(object: Object) -> String:
	if object == null:
		return ""
	var script: Script = object.get_script()
	if script == null:
		return ""
	return script.get_global_name()
