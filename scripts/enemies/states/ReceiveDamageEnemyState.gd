class_name ReceiveDamageEnemyState
extends EnemyState

func on_enter_state() -> void:
    var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
    var damage: int = general_enemy_state_blackboard.receiving_damage_amount
    if damage > 0:
        general_enemy_state_blackboard.current_health = max(0, general_enemy_state_blackboard.current_health - damage)
    activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass