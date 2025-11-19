class_name Enemy
extends CharacterBody3D

@export_group("Nodes")
@export var _animation_player: AnimationPlayer
@export var _charge_attack_animation: Animation
@export var _attacking_animation: Animation
@export var _navigation_agent_3d: NavigationAgent3D
@export var _detection_range_shape_cast_3d: ShapeCast3D
@export var _line_of_sight_ray_cast_3d: RayCast3D
@export var _debug_label_3d: Label3D
@export_group("Variables")
@export var _line_of_sight_range_scale: float = 7.0
@export var _line_of_sight_recalculation_interval_seconds: float = 0.2
@export var _target_position_recalculation_interval_seconds: float = 0.2
@export var _base_move_speed: float = 3.0
@export var _default_friction: float = 0.0
@export_subgroup("Chasing Player")
@export var _chase_player_desired_distance: float = 2.0
@export_subgroup("Attacking Player")
@export var _attack_cooldown_seconds: float = 1.0
@export var _attack_friction: float = 10.0

# State Machine
var _root_state: EnemyState = null
var _blackboard: EnemyStateBlackboard = null
var _friction: float = 0.0

func _ready() -> void:
	var player_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_player_layer()
	var walls_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_walls_layer()
	_detection_range_shape_cast_3d.collision_mask = player_layer
	_line_of_sight_ray_cast_3d.collision_mask = player_layer | walls_layer

func init(navigation_region_3d: NavigationRegion3D) -> void:
	_blackboard = GeneralEnemyStateBlackboard.new()
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	general_enemy_state_blackboard.navigation_region_3d = navigation_region_3d

	_detection_range_shape_cast_3d.set_scale(Vector3(_line_of_sight_range_scale, _line_of_sight_range_scale, _line_of_sight_range_scale))

	_setup_states()
	_root_state.enter_as_state_machine()

func _setup_states() -> void:
	var root_state: EnemyState = EmptyEnemyState.new()
	root_state.setup_init("Root", self)
	_root_state = root_state

	var watchful_state: EnemyState = WatchfulEnemyState.new()
	watchful_state.setup_init("Watchful", self)
	root_state.setup_add_sub_state(watchful_state)

	var hunting_state: EnemyState = EmptyEnemyState.new()
	hunting_state.setup_init("Hunting", self)
	root_state.setup_add_sub_state(hunting_state)
	root_state.setup_add_state_transition(watchful_state, hunting_state, PlayerSpottedTrigger.new())
	root_state.setup_add_state_transition(hunting_state, watchful_state, PlayerDisappearedTrigger.new())

	var chase_player_state: EnemyState = ChasePlayerEnemyState.new()
	chase_player_state.setup_init("ChasePlayer", self)
	hunting_state.setup_add_sub_state(chase_player_state)

	var charge_attack_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	charge_attack_state.setup_init("ChargeAttack", self)
	charge_attack_state.setup_state_vars(_animation_player, _charge_attack_animation)
	hunting_state.setup_add_sub_state(charge_attack_state)
	hunting_state.setup_add_state_transition(chase_player_state, charge_attack_state, PlayerReachedTrigger.new())

	var wait_for_charge_attack_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	wait_for_charge_attack_state.setup_init("WaitForChargeAttack", self)
	wait_for_charge_attack_state.setup_state_vars(_animation_player, _charge_attack_animation)
	hunting_state.setup_add_sub_state(wait_for_charge_attack_state)
	hunting_state.setup_add_state_transition(charge_attack_state, wait_for_charge_attack_state, StateCompleteTrigger.new())

	var attacking_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	attacking_state.setup_init("Attacking", self)
	attacking_state.setup_state_vars(_animation_player, _attacking_animation)
	hunting_state.setup_add_sub_state(attacking_state)
	hunting_state.setup_add_state_transition(wait_for_charge_attack_state, attacking_state, StateCompleteTrigger.new())

	var attack_apply_force_state: ApplyForceEnemyState = ApplyForceEnemyState.new()
	attack_apply_force_state.setup_init("AttackApplyForce", self)
	attack_apply_force_state.setup_state_vars(10.0)
	hunting_state.setup_add_sub_state(attack_apply_force_state)
	hunting_state.setup_add_state_transition(attacking_state, attack_apply_force_state, StateCompleteTrigger.new())

	var attack_set_friction_state: SetFrictionEnemyState = SetFrictionEnemyState.new()
	attack_set_friction_state.setup_init("AttackSetFriction", self)
	attack_set_friction_state.setup_state_vars(_attack_friction)
	hunting_state.setup_add_sub_state(attack_set_friction_state)
	hunting_state.setup_add_state_transition(attack_apply_force_state, attack_set_friction_state, StateCompleteTrigger.new())

	var wait_for_attacking_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	wait_for_attacking_state.setup_init("WaitForAttacking", self)
	wait_for_attacking_state.setup_state_vars(_animation_player, _attacking_animation)
	hunting_state.setup_add_sub_state(wait_for_attacking_state)
	hunting_state.setup_add_state_transition(attack_set_friction_state, wait_for_attacking_state, StateCompleteTrigger.new())

	var attack_set_velocity_state: SetVelocityEnemyState = SetVelocityEnemyState.new()
	attack_set_velocity_state.setup_init("AttackSetVelocity", self)
	attack_set_velocity_state.setup_state_vars(Vector3.ZERO)
	hunting_state.setup_add_sub_state(attack_set_velocity_state)
	hunting_state.setup_add_state_transition(wait_for_attacking_state, attack_set_velocity_state, StateCompleteTrigger.new())

	var attack_restore_friction_state: SetFrictionEnemyState = SetFrictionEnemyState.new()
	attack_restore_friction_state.setup_init("AttackRestoreFriction", self)
	attack_restore_friction_state.setup_state_vars(_default_friction)
	hunting_state.setup_add_sub_state(attack_restore_friction_state)
	hunting_state.setup_add_state_transition(attack_set_velocity_state, attack_restore_friction_state, StateCompleteTrigger.new())

	var attack_cooldown_state: WaitForDurationEnemyState = WaitForDurationEnemyState.new()
	attack_cooldown_state.setup_init("AttackCooldown", self)
	attack_cooldown_state.setup_state_vars(_attack_cooldown_seconds)
	hunting_state.setup_add_sub_state(attack_cooldown_state)
	hunting_state.setup_add_state_transition(attack_restore_friction_state, attack_cooldown_state, StateCompleteTrigger.new())
	hunting_state.setup_add_state_transition(attack_cooldown_state, chase_player_state, StateCompleteTrigger.new())

func get_blackboard() -> EnemyStateBlackboard:
	return _blackboard

func get_navigation_agent_3d() -> NavigationAgent3D:
	return _navigation_agent_3d

func get_debug_label_3d() -> Label3D:
	return _debug_label_3d

func get_line_of_sight_recalculation_interval_seconds() -> float:
	return _line_of_sight_recalculation_interval_seconds

func get_target_position_recalculation_interval_seconds() -> float:
	return _target_position_recalculation_interval_seconds

func get_base_move_speed() -> float:
	return _base_move_speed

func get_chase_player_desired_distance() -> float:
	return _chase_player_desired_distance

func set_friction(friction: float) -> void:
	_friction = friction

func _process(delta: float) -> void:
	_debug_label_3d.text = ""
	if _root_state == null:
		return
	_root_state.process_as_state_machine(delta)

func _physics_process(delta: float) -> void:
	if _root_state == null:
		return
	_root_state.physics_process_as_state_machine(delta)

	var friction: float = _friction
	var current_velocity: Vector3 = get_velocity()
	var new_velocity: Vector3 = current_velocity.move_toward(Vector3.ZERO, friction * delta)
	set_velocity(new_velocity)

	move_and_slide()

func get_player_in_line_of_sight() -> PlayerController3D:
	_detection_range_shape_cast_3d.force_shapecast_update()

	if !_detection_range_shape_cast_3d.is_colliding():
		_debug_label_3d.text = "No player in detection range"
		return null
	
	var candidate_players: Array[PlayerController3D] = []
	var collisions_count: int = _detection_range_shape_cast_3d.get_collision_count()
	for i: int in range(collisions_count):
		var collider: Node3D = _detection_range_shape_cast_3d.get_collider(i)
		if collider.is_in_group("player"):
			candidate_players.append(collider as PlayerController3D)
	
	if candidate_players.size() == 0:
		_debug_label_3d.text = "No candidate players"
		return null
	
	var player_in_line_of_sight: PlayerController3D = null
	for candidate_player: PlayerController3D in candidate_players:
		var candidate_player_relative_position: Vector3 = candidate_player.get_global_position() - _line_of_sight_ray_cast_3d.get_global_position()
		candidate_player_relative_position.y = 0
		_line_of_sight_ray_cast_3d.set_target_position(candidate_player_relative_position)
		_line_of_sight_ray_cast_3d.force_raycast_update()
		if !_line_of_sight_ray_cast_3d.is_colliding():
			continue
		
		var collider: Node3D = _line_of_sight_ray_cast_3d.get_collider()
		if collider.is_in_group("player"):
			player_in_line_of_sight = candidate_player
			break
	
	if player_in_line_of_sight != null:
		return player_in_line_of_sight
	else:
		_debug_label_3d.text = "No player in line of sight"
		return null
