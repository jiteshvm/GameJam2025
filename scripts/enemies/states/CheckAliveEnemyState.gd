class_name CheckAliveEnemyState
extends EnemyState

func on_enter_state() -> void:
    var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
    if general_enemy_state_blackboard.current_health <= 0:
        activate_trigger(EnemyHealthZeroTrigger.new())
    else:
        activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass