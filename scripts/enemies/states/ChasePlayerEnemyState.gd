class_name ChasePlayerEnemyState
extends EnemyState

func on_enter_state() -> void:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	var player_in_line_of_sight: PlayerController3D = _enemy.get_player_in_line_of_sight()
	general_enemy_state_blackboard.player_in_line_of_sight = player_in_line_of_sight
	if player_in_line_of_sight != null:
		general_enemy_state_blackboard.last_known_player_position = player_in_line_of_sight.get_global_position()

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
		if player_in_line_of_sight != null:
			general_enemy_state_blackboard.last_known_player_position = player_in_line_of_sight.get_global_position()

	_physics_process_target_position_recalculation(delta)
	var next_path_position: Vector3 = _enemy.get_navigation_agent_3d().get_next_path_position()
	var direction: Vector3 = (next_path_position - _enemy.get_global_position()).normalized()
	var move_speed: float = _enemy.get_base_move_speed()
	_enemy.set_velocity(direction * move_speed)

	var distance_to_player: float = (general_enemy_state_blackboard.last_known_player_position - _enemy.get_global_position()).length()
	if distance_to_player <= _enemy.get_chase_player_desired_distance():
		_enemy.set_velocity(Vector3.ZERO)
		if general_enemy_state_blackboard.player_in_line_of_sight != null:
			var force_direction: Vector3 = (general_enemy_state_blackboard.player_in_line_of_sight.get_global_position() - _enemy.get_global_position()).normalized()
			general_enemy_state_blackboard.force_direction = force_direction
			activate_trigger(PlayerReachedTrigger.new())
		else:
			activate_trigger(PlayerDisappearedTrigger.new())

func _physics_process_target_position_recalculation(delta: float) -> void:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	general_enemy_state_blackboard.target_position_recalculation_timer_seconds += delta
	if general_enemy_state_blackboard.target_position_recalculation_timer_seconds < _enemy.get_target_position_recalculation_interval_seconds():
		return
	general_enemy_state_blackboard.target_position_recalculation_timer_seconds = 0.0
	_enemy.get_navigation_agent_3d().set_target_position(general_enemy_state_blackboard.last_known_player_position)
