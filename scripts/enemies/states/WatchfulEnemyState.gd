class_name WatchfulEnemyState
extends EnemyState

func on_enter_state() -> void:
	pass

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	general_enemy_state_blackboard.line_of_sight_recalculation_timer_seconds += delta
	if general_enemy_state_blackboard.line_of_sight_recalculation_timer_seconds >= _enemy.get_line_of_sight_recalculation_interval_seconds():
		general_enemy_state_blackboard.line_of_sight_recalculation_timer_seconds = 0.0
		var player_in_line_of_sight: PlayerController3D = _enemy.get_player_in_line_of_sight()
		general_enemy_state_blackboard.player_in_line_of_sight = player_in_line_of_sight

		if general_enemy_state_blackboard.player_in_line_of_sight != null:
			general_enemy_state_blackboard.last_known_player_position = player_in_line_of_sight.get_global_position()
			activate_trigger(PlayerSpottedTrigger.new())
