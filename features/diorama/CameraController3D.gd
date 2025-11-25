class_name CameraController3D
extends Node3D

@export var _camera_3d: Camera3D
@export var smoothing: float = 8.0

var _target_position: Vector3

func _ready() -> void:
	add_to_group("player_camera_controller_3d")

	_target_position = global_position
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p: Node3D = players[0] as Node3D
		if p and p.has_signal("moved"):
			p.connect("moved", Callable(self, "_on_player_moved"))
			_target_position = p.global_position
			global_position = _target_position

func _process(delta: float) -> void:
	var desired: Vector3 = _target_position
	var t: float = clamp(smoothing * delta, 0.0, 1.0)
	global_position = global_position.lerp(desired, t)

func get_camera_3d() -> Camera3D:
	return _camera_3d

func _on_player_moved(pos: Vector3) -> void:
	_target_position = pos
