class_name PlayerController3D
extends CharacterBody3D

signal moved(new_global_position: Vector3)

@export var max_speed: float = 6.0
@export var accel: float = 14.0
@export var decel: float = 18.0
@export var gamepad_deadzone: float = 0.18

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var idle_texture: Texture2D = preload("res://assets/gauss/gauss_idle.png")
@export var movement_texture: Texture2D = preload("res://assets/gauss/gauss_movement.png")
@export var attack_damage: int = 1
@export var attack_knockback: float = 6.0
@export var attack_cooldown_ms: int = 450
@export var attack_active_ms: int = 180
@export var attack_hitbox_forward_distance: float = 0.5
@export var attack_hitbox_vertical_offset: float = 0.45
@export var attack_hitbox_size: Vector3 = Vector3(0.6, 0.85, 1.2)
@export var debug_attack_visualization: bool = true
@export var debug_attack_logging: bool = true

const ATTACK_DEBUG_COLOR_DEFAULT := Color(1, 0.188235, 0.188235, 0.631373)
const ATTACK_DEBUG_COLOR_HIT := Color(0.16, 0.95, 0.16, 0.7)

var _input_dir: Vector2 = Vector2.ZERO
var _camera: Camera3D
@onready var _sprite: Sprite3D = $Sprite3D
@onready var _attack_hitbox: Area3D = $AttackHitbox
@onready var _attack_hitbox_shape: CollisionShape3D = $"AttackHitbox/CollisionShape3D"
@onready var _attack_debug_mesh: MeshInstance3D = $"AttackHitbox/DebugMesh"
var _attack_debug_material: StandardMaterial3D
var _active_sprite_texture: Texture2D = null
var _facing_left: bool = false
var _is_attack_active: bool = false
var _attack_active_end_ms: int = 0
var _attack_cooldown_end_ms: int = 0
var _hit_enemies: Array[Enemy] = []
var _attack_forward_dir: Vector3 = Vector3(1, 0, 0)
var _attack_debug_hit_flash_end_ms: int = 0

func _ready() -> void:
	add_to_group("player")
	_camera = get_viewport().get_camera_3d()
	_update_sprite_texture(false)
	_update_attack_hitbox_transform()
	_apply_attack_hitbox_size()
	if _attack_debug_mesh:
		if _attack_debug_mesh.material_override:
			_attack_debug_material = _attack_debug_mesh.material_override.duplicate()
		else:
			_attack_debug_material = StandardMaterial3D.new()
		_attack_debug_material.albedo_color = ATTACK_DEBUG_COLOR_DEFAULT
		_attack_debug_mesh.material_override = _attack_debug_material
	_update_attack_debug_visibility()
	if _attack_hitbox:
		_attack_hitbox.monitoring = false
		_attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
		if CollisionLayersManager.get_instance():
			var enemy_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_enemy_layer()
			_attack_hitbox.collision_mask = enemy_layer
	_update_attack_forward_dir()

func _physics_process(delta: float) -> void:
	var now_ms: int = Time.get_ticks_msec()
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

	_update_sprite_texture(wishdir != Vector3.ZERO)
	_update_sprite_facing(_input_dir)
	_update_attack_forward_dir()
	_update_attack_hitbox_transform()
	_handle_attack_input(now_ms)
	_update_attack_state(now_ms)

	# Apply gravity when not grounded; clear residual when grounded.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	move_and_slide()
	moved.emit(global_position)

func _update_sprite_texture(is_moving: bool) -> void:
	if _sprite == null:
		return
	var desired: Texture2D = idle_texture
	if is_moving and movement_texture != null:
		desired = movement_texture
	elif desired == null and movement_texture != null:
		desired = movement_texture
	if desired == null or desired == _active_sprite_texture:
		return
	_active_sprite_texture = desired
	_sprite.texture = desired

func _handle_attack_input(now_ms: int) -> void:
	if Input.is_action_just_pressed("attack") and now_ms >= _attack_cooldown_end_ms and not _is_attack_active:
		_start_attack(now_ms)

func _start_attack(now_ms: int) -> void:
	_is_attack_active = true
	_attack_active_end_ms = now_ms + attack_active_ms
	_attack_cooldown_end_ms = now_ms + attack_cooldown_ms
	_hit_enemies.clear()
	_set_attack_hitbox_enabled(true)
	_update_attack_debug_visibility()
	_set_attack_debug_color(ATTACK_DEBUG_COLOR_DEFAULT)
	_attack_debug_hit_flash_end_ms = 0
	_debug_log("Attack started at %s" % now_ms)
	_process_attack_overlaps(now_ms)

func _update_attack_state(now_ms: int) -> void:
	if _is_attack_active and now_ms >= _attack_active_end_ms:
		_is_attack_active = false
		_set_attack_hitbox_enabled(false)
		_update_attack_debug_visibility()
		_debug_log("Attack ended at %s" % now_ms)
	elif _is_attack_active:
		_process_attack_overlaps(now_ms)
	_update_attack_debug_color(now_ms)

func _set_attack_hitbox_enabled(enabled: bool) -> void:
	if _attack_hitbox == null or _attack_hitbox_shape == null:
		return
	_attack_hitbox.monitoring = enabled
	_attack_hitbox.set_deferred("monitoring", enabled)
	_attack_hitbox_shape.set_deferred("disabled", not enabled)

func _update_attack_hitbox_transform() -> void:
	if _attack_hitbox == null:
		return
	var forward: Vector3 = _attack_forward_dir
	if forward.length() == 0.0:
		forward = Vector3.RIGHT if not _facing_left else Vector3.LEFT
	forward = forward.normalized()
	var up: Vector3 = Vector3.UP
	var side: Vector3 = forward.cross(up)
	if side.length() == 0.0:
		side = Vector3.FORWARD
	side = side.normalized()
	var basis: Basis = Basis(forward, up, side)
	var offset: Vector3 = (forward * attack_hitbox_forward_distance) + (up * attack_hitbox_vertical_offset)
	_attack_hitbox.transform = Transform3D(basis, offset)

func _apply_attack_hitbox_size() -> void:
	if _attack_hitbox_shape and _attack_hitbox_shape.shape is BoxShape3D:
		var shape: BoxShape3D = _attack_hitbox_shape.shape as BoxShape3D
		shape.size = attack_hitbox_size
	if _attack_debug_mesh and _attack_debug_mesh.mesh is BoxMesh:
		var box_mesh: BoxMesh = _attack_debug_mesh.mesh as BoxMesh
		box_mesh.size = attack_hitbox_size

func _on_attack_hitbox_body_entered(body: Node) -> void:
	_handle_attack_hit_body(body, Time.get_ticks_msec())

func _handle_attack_hit_body(body: Node, now_ms: int) -> void:
	if not _is_attack_active:
		return
	if body == self:
		return
	if body is Enemy:
		var enemy: Enemy = body as Enemy
		if _hit_enemies.has(enemy):
			return
		_hit_enemies.append(enemy)
		var push_vec: Vector3 = (enemy.global_position - global_position)
		push_vec.y = 0.0
		if push_vec.length() == 0.0:
			push_vec = Vector3.LEFT if _facing_left else Vector3.RIGHT
		push_vec = push_vec.normalized() * attack_knockback
		enemy.apply_hit(attack_damage, push_vec)
		_debug_log("Hit enemy %s" % enemy.get_instance_id())
		_flash_attack_debug_hit(now_ms)

func _process_attack_overlaps(now_ms: int) -> void:
	if _attack_hitbox == null or not _attack_hitbox.monitoring:
		return
	var bodies := _attack_hitbox.get_overlapping_bodies()
	for body in bodies:
		_handle_attack_hit_body(body, now_ms)

func _update_attack_debug_visibility() -> void:
	if _attack_debug_mesh:
		_attack_debug_mesh.visible = debug_attack_visualization and _is_attack_active

func _set_attack_debug_color(color: Color) -> void:
	if _attack_debug_material == null:
		return
	_attack_debug_material.albedo_color = color

func _flash_attack_debug_hit(now_ms: int) -> void:
	if not debug_attack_visualization:
		return
	_set_attack_debug_color(ATTACK_DEBUG_COLOR_HIT)
	_attack_debug_hit_flash_end_ms = now_ms + 120

func _update_attack_debug_color(now_ms: int) -> void:
	if _attack_debug_hit_flash_end_ms == 0:
		return
	if now_ms >= _attack_debug_hit_flash_end_ms:
		_attack_debug_hit_flash_end_ms = 0
		_set_attack_debug_color(ATTACK_DEBUG_COLOR_DEFAULT)

func _debug_log(message: String) -> void:
	if debug_attack_logging:
		print("[PlayerAttack] %s" % message)

func _update_sprite_facing(movement: Vector2) -> void:
	if _sprite == null:
		return
	if movement.x == 0.0:
		return
	var should_face_left: bool = movement.x < 0.0
	if should_face_left == _facing_left:
		return
	_facing_left = should_face_left
	_sprite.flip_h = _facing_left
	_update_attack_forward_dir()
	_update_attack_hitbox_transform()

func _update_attack_forward_dir() -> void:
	var dir: Vector3 = Vector3.RIGHT
	if _camera != null:
		dir = _camera.global_basis.x
	dir.y = 0.0
	if dir.length() == 0.0:
		dir = Vector3.RIGHT
	dir = dir.normalized()
	_attack_forward_dir = (-dir if _facing_left else dir)
