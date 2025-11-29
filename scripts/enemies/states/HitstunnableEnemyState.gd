class_name HitstunnableEnemyState
extends EnemyState

var _force_sub_state: EnemyState = null

func setup_state_vars(force_sub_state: EnemyState) -> void:
	_force_sub_state = force_sub_state

func on_enter_state() -> void:
	force_change_sub_state(_force_sub_state)

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	pass
