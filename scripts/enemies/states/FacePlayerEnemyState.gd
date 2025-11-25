class_name FacePlayerEnemyState
extends EnemyState

func on_enter_state() -> void:
    _face_player()

func on_exit_state() -> void:
    pass

func on_process_state(delta: float) -> void:
    _enemy.get_debug_label_3d().text += "%s\n" % _state_name


func on_physics_process_state(delta: float) -> void:
    _face_player()

func _face_player() -> void:
    var blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
    var player_global_position: Vector3 = blackboard.player.get_global_position()
    var enemy_global_position: Vector3 = _enemy.get_global_position()
    var direction: Vector3 = (player_global_position - enemy_global_position).normalized()
    direction.y = 0.0

    # Adjust rotation relative to player camera
    var player_camera_global_basis: Basis = blackboard.player_camera_controller_3d.get_camera_3d().global_transform.basis
    var adjusted_direction: Vector3 = player_camera_global_basis * direction
    direction = adjusted_direction

    direction = direction.rotated(Vector3.UP, -PI / 2.0)

    _enemy.get_sprite_3d().flip_h = direction.x < 0.0