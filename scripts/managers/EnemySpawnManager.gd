class_name EnemySpawnManager
extends Node

@export_group("Packed Scenes")
@export var _enemy_spawner_packed_scene: PackedScene
@export var _enemy_packed_scene: PackedScene
@export_group("Nodes")
@export var _spawn_points: Array[Node3D]
@export var _enemies_container: Node3D
@export var _navigation_region_3d: NavigationRegion3D

var _enemy_spawners: Array[EnemySpawner] = []
var _enemies: Array[Enemy] = []

func _ready() -> void:
	for spawn_point: Node3D in _spawn_points:
		_create_enemy_spawner(spawn_point)

func _create_enemy_spawner(spawn_point: Node3D) -> void:
	var enemy_spawner: EnemySpawner = _enemy_spawner_packed_scene.instantiate()
	_enemies_container.add_child(enemy_spawner)
	enemy_spawner.init(_enemy_packed_scene, _enemies_container, _navigation_region_3d)
	enemy_spawner.global_position = spawn_point.global_position
	enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)

func _remove_enemy_spawner(enemy_spawner: EnemySpawner) -> void:
	_enemy_spawners.erase(enemy_spawner)

func _on_enemy_spawned(enemy_spawner: EnemySpawner, enemy: Enemy) -> void:
	_remove_enemy_spawner(enemy_spawner)
	_add_enemy(enemy)

func _add_enemy(enemy: Enemy) -> void:
	_enemies.append(enemy)
	enemy.enemy_died.connect(_on_enemy_died)

func _remove_enemy(enemy: Enemy) -> void:
	_enemies.erase(enemy)

func _on_enemy_died(enemy: Enemy) -> void:
	_remove_enemy(enemy)
	print("Enemy died: %s" % enemy)
