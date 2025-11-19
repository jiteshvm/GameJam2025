class_name EnemySpawnManager
extends Node

@export var _enemy_packed_scene: PackedScene
@export var _spawn_points: Array[Node3D]
@export var _enemies_container: Node3D
@export var _navigation_region_3d: NavigationRegion3D

func _ready() -> void:
    for spawn_point: Node3D in _spawn_points:
        _spawn_enemy(spawn_point)

func _spawn_enemy(spawn_point: Node3D) -> void:
    var enemy: Enemy = _enemy_packed_scene.instantiate()
    _enemies_container.add_child(enemy)
    enemy.init(_navigation_region_3d)
    enemy.global_position = spawn_point.global_position