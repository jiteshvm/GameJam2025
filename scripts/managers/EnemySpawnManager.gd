class_name EnemySpawnManager
extends Node

@export var _enemy_spawner_packed_scene: PackedScene
@export var _enemy_packed_scene: PackedScene
@export var _spawn_points: Array[Node3D]
@export var _enemies_container: Node3D
@export var _navigation_region_3d: NavigationRegion3D

func _ready() -> void:
	for spawn_point: Node3D in _spawn_points:
		_create_enemy_spawner(spawn_point)

func _create_enemy_spawner(spawn_point: Node3D) -> void:
	var enemy_spawner: EnemySpawner = _enemy_spawner_packed_scene.instantiate()
	_enemies_container.add_child(enemy_spawner)
	enemy_spawner.init(_enemy_packed_scene, _enemies_container, _navigation_region_3d)
	enemy_spawner.global_position = spawn_point.global_position
