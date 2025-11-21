class_name ChasePlayerEnemyState
extends EnemyState

# Ephemeral
var _chase_timer_seconds: float = 0.0

func on_enter_state() -> void:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	var player_in_line_of_sight: PlayerController3D = _enemy.get_player_in_line_of_sight()
	general_enemy_state_blackboard.player_in_line_of_sight = player_in_line_of_sight

	_chase_timer_seconds = 0.0

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	_chase_timer_seconds += delta
	if _chase_timer_seconds >= _enemy.get_max_chase_duration_seconds():
		activate_trigger(MaxChaseDurationReachedTrigger.new())
		return

	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard

	general_enemy_state_blackboard.target_position_recalculation_timer_seconds += delta
	if general_enemy_state_blackboard.target_position_recalculation_timer_seconds >= _enemy.get_target_position_recalculation_interval_seconds():
		general_enemy_state_blackboard.target_position_recalculation_timer_seconds = 0.0
		_enemy.get_navigation_agent_3d().set_target_position(general_enemy_state_blackboard.player.get_global_position())

	if _enemy.get_velocity().length() < _enemy.get_base_desired_move_speed():
		var next_path_position: Vector3 = _enemy.get_navigation_agent_3d().get_next_path_position()
		var direction: Vector3 = (next_path_position - _enemy.get_global_position()).normalized()
		direction.y = 0.0
		var move_acceleration: float = _enemy.get_base_move_acceleration()
		_enemy.set_velocity(_enemy.get_velocity().move_toward(direction * _enemy.get_base_desired_move_speed(), move_acceleration * delta))

	var distance_to_player: float = (general_enemy_state_blackboard.player.get_global_position() - _enemy.get_global_position()).length()
	if distance_to_player <= _enemy.get_chase_player_desired_distance():
		var player_in_line_of_sight: PlayerController3D = _enemy.get_player_in_line_of_sight()
		if player_in_line_of_sight != null:
			general_enemy_state_blackboard.player_in_line_of_sight = player_in_line_of_sight
			activate_trigger(PlayerReachedTrigger.new())
