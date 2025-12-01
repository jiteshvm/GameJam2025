class_name DestroySelfEnemyState
extends EnemyState

func on_enter_state() -> void:
    _enemy.internal_handle_death()

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass