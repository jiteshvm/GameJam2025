class_name CollisionLayersDefinition
extends Resource

@export_flags_3d_physics var _player_layer: int
@export_flags_3d_physics var _enemy_layer: int
@export_flags_3d_physics var _walls_layer: int

func get_player_layer() -> int:
    return _player_layer

func get_enemy_layer() -> int:
    return _enemy_layer

func get_walls_layer() -> int:
    return _walls_layer