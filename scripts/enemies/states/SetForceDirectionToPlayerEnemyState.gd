class_name SetForceDirectionToPlayerEnemyState
extends EnemyState

var _is_towards_player: bool = false

func setup_state_vars(is_towards_player: bool) -> void:
	_is_towards_player = is_towards_player

func on_enter_state() -> void:
	var blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	blackboard.force_direction = (blackboard.player.get_global_position() - _enemy.get_global_position()).normalized()
	blackboard.force_direction.y = 0.0
	if !_is_towards_player:
		blackboard.force_direction = -blackboard.force_direction
	activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	pass
