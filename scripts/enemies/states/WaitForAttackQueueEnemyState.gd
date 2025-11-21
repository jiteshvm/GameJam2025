class_name WaitForAttackQueueEnemyState
extends EnemyState

func on_enter_state() -> void:
    EnemyAttackTimingManager.get_instance().add_enemy_to_attack_queue(_enemy)

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

    if !EnemyAttackTimingManager.get_instance().is_enemy_still_in_attack_queue(_enemy):
        activate_trigger(EnemyFailAttackQueueTrigger.new())
        return

    if EnemyAttackTimingManager.get_instance().is_enemy_next_in_attack_queue(_enemy):
        activate_trigger(EnemySuccessAttackQueueTrigger.new())
        return

func on_physics_process_state(delta: float) -> void:
    pass
