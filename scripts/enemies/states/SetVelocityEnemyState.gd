class_name SetVelocityEnemyState
extends EnemyState

var _velocity: Vector3 = Vector3.ZERO

func setup_state_vars(velocity: Vector3) -> void:
    _velocity = velocity

func on_enter_state() -> void:
    _enemy.set_velocity(_velocity)
    activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass