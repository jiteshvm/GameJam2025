class_name PlayAnimationEnemyState
extends EnemyState

var _animation_player: AnimationPlayer = null
var _animation: Animation = null

func setup_state_vars(animation_player: AnimationPlayer, animation: Animation) -> void:
	_animation_player = animation_player
	_animation = animation

func on_enter_state() -> void:
	_animation_player.play(_animation.resource_name)
	activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	pass
