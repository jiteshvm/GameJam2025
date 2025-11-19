class_name SetFrictionEnemyState
extends EnemyState

var _friction: float = 0.0

func setup_state_vars(friction: float) -> void:
    _friction = friction

func on_enter_state() -> void:
    _enemy.set_friction(_friction)
    activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass