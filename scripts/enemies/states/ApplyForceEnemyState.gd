class_name ApplyForceEnemyState
extends EnemyState

var _intensity: float = 0.0

func setup_state_vars(intensity: float) -> void:
    _intensity = intensity

func on_enter_state() -> void:
    var blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
    var force_direction: Vector3 = blackboard.force_direction
    var force: Vector3 = force_direction * _intensity

    var new_velocity: Vector3 = force
    _enemy.set_velocity(new_velocity)

    activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
    pass