class_name PlayerController3D
extends CharacterBody3D

signal moved(new_global_position: Vector3)

@export var max_speed: float = 6.0
@export var accel: float = 14.0
@export var decel: float = 18.0
@export var gamepad_deadzone: float = 0.18

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _input_dir: Vector2 = Vector2.ZERO
var _camera: Camera3D

func _ready() -> void:
	add_to_group("player")
	_camera = get_viewport().get_camera_3d()

func _physics_process(delta: float) -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_3d()

	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back", gamepad_deadzone)
	var input_len: float = _input_dir.length()
	if input_len > 1.0:
		_input_dir /= input_len

	var right: Vector3 = Vector3(1, 0, 0)
	var forward: Vector3 = Vector3(0, 0, -1)
	if _camera != null:
		right = _camera.global_basis.x
		forward = -_camera.global_basis.z
		right.y = 0.0
		forward.y = 0.0
		var r_len: float = right.length()
		if r_len != 0.0:
			right /= r_len
		var f_len: float = forward.length()
		if f_len != 0.0:
			forward /= f_len

	var wishdir: Vector3 = Vector3.ZERO
	if _input_dir != Vector2.ZERO:
		wishdir = (right * _input_dir.x) + (forward * -_input_dir.y)
		var w_len: float = wishdir.length()
		if w_len != 0.0:
			wishdir /= w_len

	var target_v: Vector3 = wishdir * max_speed
	if wishdir != Vector3.ZERO:
		var t: float = clamp(accel * delta, 0.0, 1.0)
		velocity.x = lerp(velocity.x, target_v.x, t)
		velocity.z = lerp(velocity.z, target_v.z, t)
	else:
		var drop: float = decel * delta
		velocity.x = move_toward(velocity.x, 0.0, drop)
		velocity.z = move_toward(velocity.z, 0.0, drop)

	# Apply gravity when not grounded; clear residual when grounded.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	move_and_slide()
	moved.emit(global_position)
