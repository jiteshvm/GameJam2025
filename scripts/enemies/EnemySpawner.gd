class_name EnemySpawner
extends Node3D

@export var _detection_radius_scale: float = 3.0
@export var _detection_area_3d: Area3D

var _enemy_packed_scene: PackedScene = null
var _enemies_container: Node3D = null
var _navigation_region_3d: NavigationRegion3D = null

func init(enemy_packed_scene: PackedScene, enemies_container: Node3D, navigation_region_3d: NavigationRegion3D) -> void:
	_enemy_packed_scene = enemy_packed_scene
	_enemies_container = enemies_container
	_navigation_region_3d = navigation_region_3d

	var player_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_player_layer()
	_detection_area_3d.collision_mask = player_layer

	_detection_area_3d.set_scale(Vector3(_detection_radius_scale, _detection_radius_scale, _detection_radius_scale))
	_detection_area_3d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var enemy: Enemy = _enemy_packed_scene.instantiate()
		_enemies_container.add_child(enemy)
		enemy.init(_navigation_region_3d)
		enemy.global_position = global_position
		_destroy_spawner()

func _destroy_spawner() -> void:
	queue_free()
