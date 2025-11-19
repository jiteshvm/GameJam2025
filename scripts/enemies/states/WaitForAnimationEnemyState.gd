class_name WaitForAnimationEnemyState
extends EnemyState

var _animation_player: AnimationPlayer = null
var _animation: Animation = null

func setup_state_vars(animation_player: AnimationPlayer, animation: Animation) -> void:
    _animation_player = animation_player
    _animation = animation

func on_enter_state() -> void:
    if _animation_player.get_current_animation() != _animation.resource_name:
        _on_animation_finished()

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name

    if !_animation_player.is_playing():
        _on_animation_finished()


func on_physics_process_state(delta: float) -> void:
    pass

func _on_animation_finished() -> void:
    activate_trigger(StateCompleteTrigger.new())