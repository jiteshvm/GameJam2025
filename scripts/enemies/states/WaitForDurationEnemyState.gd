class_name WaitForDurationEnemyState
extends EnemyState

var _duration: float = 0.0
# Ephemeral
var _duration_remaining: float = 0.0

func setup_state_vars(duration: float) -> void:
    _duration = duration

func on_enter_state() -> void:
    _duration_remaining = _duration

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s: %f\n" % [_state_name, _duration_remaining]

    _duration_remaining -= delta
    if _duration_remaining <= 0.0:
        activate_trigger(StateCompleteTrigger.new())

func on_physics_process_state(delta: float) -> void:
    pass