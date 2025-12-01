class_name Enemy
extends CharacterBody3D

@export_group("Packed Scenes")
@export var _enemy_death_particles_packed_scene: PackedScene
@export_group("Nodes")
@export var _animation_player: AnimationPlayer
@export var _weak_enemy_spawn_animation: Animation
@export var _weak_enemy_idle_animation: Animation
@export var _weak_enemy_chase_animation: Animation
@export var _weak_enemy_charge_attack_animation: Animation
@export var _weak_enemy_attacking_animation: Animation
@export var _weak_enemy_hitstunned_animation: Animation
@export var _weak_enemy_death_animation: Animation
@export var _aggressive_enemy_spawn_animation: Animation
@export var _aggressive_enemy_idle_animation: Animation
@export var _aggressive_enemy_chase_animation: Animation
@export var _aggressive_enemy_charge_attack_animation: Animation
@export var _aggressive_enemy_attacking_animation: Animation
@export var _aggressive_enemy_hitstunned_animation: Animation
@export var _aggressive_enemy_death_animation: Animation
@export var _navigation_agent_3d: NavigationAgent3D
@export var _detection_range_shape_cast_3d: ShapeCast3D
@export var _line_of_sight_ray_cast_3d: RayCast3D
@export var _sprite_3d: Sprite3D
@export var _hit_flash_sprite_3d: Sprite3D
@export var _debug_label_3d: Label3D
@export_group("Variables")
@export var _gravity: float = 9.81
@export var _line_of_sight_range_scale: float = 7.0
@export var _target_position_recalculation_interval_seconds: float = 0.2
@export_subgroup("Movement")
@export var _weak_enemy_base_move_acceleration: float = 100.0
@export var _weak_enemy_base_desired_move_speed: float = 2.0
@export var _aggressive_enemy_base_move_acceleration: float = 150.0
@export var _aggressive_enemy_base_desired_move_speed: float = 3.5
@export var _default_friction: float = 10.0
@export_subgroup("Chasing Player")
@export var _weak_enemy_chase_player_desired_distance: float = 2.5
@export var _weak_enemy_max_chase_duration_seconds: float = 3.0
@export var _weak_enemy_chase_break_duration_seconds: float = 2.0
@export var _aggressive_enemy_chase_player_desired_distance: float = 3.0
@export var _aggressive_enemy_max_chase_duration_seconds: float = 2.0
@export var _aggressive_enemy_chase_break_duration_seconds: float = 0.75
@export_subgroup("Attacking Player")
@export var _weak_enemy_attack_cooldown_seconds: float = 1.0
@export var _weak_enemy_attack_apply_force_magnitude: float = 9.0
@export var _aggressive_enemy_attack_cooldown_seconds: float = 0.5
@export var _aggressive_enemy_attack_apply_force_magnitude: float = 12.0
@export var _attack_friction: float = 10.0
@export_subgroup("Hitstunned")
@export var _weak_enemy_hitstunned_push_force_magnitude: float = 4.0
@export var _weak_enemy_hitstunned_duration_seconds: float = 0.5
@export var _aggressive_enemy_hitstunned_push_force_magnitude: float = 6.0
@export var _aggressive_enemy_hitstunned_duration_seconds: float = 0.25
@export_subgroup("Stats")
@export var _weak_enemy_max_health: int = 4
@export var _aggressive_enemy_max_health: int = 10

signal enemy_died(enemy: Enemy)

# State Machine
var _root_state: EnemyState = null
var _blackboard: EnemyStateBlackboard = null
var _enemy_type: EnemyType
var _friction: float = 0.0

enum EnemyType {
	WEAK,
	AGGRESSIVE,
}

func init(enemy_type: EnemyType, navigation_region_3d: NavigationRegion3D) -> void:
	_enemy_type = enemy_type

	var player_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_player_layer()
	var walls_layer: int = CollisionLayersManager.get_instance().get_collision_layers_definition().get_walls_layer()
	_detection_range_shape_cast_3d.collision_mask = player_layer
	_line_of_sight_ray_cast_3d.collision_mask = player_layer | walls_layer
	
	set_friction(_default_friction)

	_blackboard = GeneralEnemyStateBlackboard.new()
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	if _enemy_type == EnemyType.WEAK:
		general_enemy_state_blackboard.max_health = _weak_enemy_max_health
		general_enemy_state_blackboard.current_health = _weak_enemy_max_health

		general_enemy_state_blackboard.spawn_animation = _weak_enemy_spawn_animation
		general_enemy_state_blackboard.idle_animation = _weak_enemy_idle_animation
		general_enemy_state_blackboard.chase_animation = _weak_enemy_chase_animation
		general_enemy_state_blackboard.charge_attack_animation = _weak_enemy_charge_attack_animation
		general_enemy_state_blackboard.attacking_animation = _weak_enemy_attacking_animation
		general_enemy_state_blackboard.hitstunned_animation = _weak_enemy_hitstunned_animation
		general_enemy_state_blackboard.death_animation = _weak_enemy_death_animation

		general_enemy_state_blackboard.base_move_acceleration = _weak_enemy_base_move_acceleration
		general_enemy_state_blackboard.base_desired_move_speed = _weak_enemy_base_desired_move_speed
		general_enemy_state_blackboard.chase_player_desired_distance = _weak_enemy_chase_player_desired_distance
		general_enemy_state_blackboard.max_chase_duration_seconds = _weak_enemy_max_chase_duration_seconds
		general_enemy_state_blackboard.chase_break_duration_seconds = _weak_enemy_chase_break_duration_seconds
		general_enemy_state_blackboard.attack_cooldown_seconds = _weak_enemy_attack_cooldown_seconds
		general_enemy_state_blackboard.attack_apply_force_magnitude = _weak_enemy_attack_apply_force_magnitude
		general_enemy_state_blackboard.hitstunned_push_force_magnitude = _weak_enemy_hitstunned_push_force_magnitude
		general_enemy_state_blackboard.hitstunned_duration_seconds = _weak_enemy_hitstunned_duration_seconds
	else:
		general_enemy_state_blackboard.max_health = _aggressive_enemy_max_health
		general_enemy_state_blackboard.current_health = _aggressive_enemy_max_health

		general_enemy_state_blackboard.spawn_animation = _aggressive_enemy_spawn_animation
		general_enemy_state_blackboard.idle_animation = _aggressive_enemy_idle_animation
		general_enemy_state_blackboard.chase_animation = _aggressive_enemy_chase_animation
		general_enemy_state_blackboard.charge_attack_animation = _aggressive_enemy_charge_attack_animation
		general_enemy_state_blackboard.attacking_animation = _aggressive_enemy_attacking_animation
		general_enemy_state_blackboard.hitstunned_animation = _aggressive_enemy_hitstunned_animation
		general_enemy_state_blackboard.death_animation = _aggressive_enemy_death_animation

		general_enemy_state_blackboard.base_move_acceleration = _aggressive_enemy_base_move_acceleration
		general_enemy_state_blackboard.base_desired_move_speed = _aggressive_enemy_base_desired_move_speed
		general_enemy_state_blackboard.chase_player_desired_distance = _aggressive_enemy_chase_player_desired_distance
		general_enemy_state_blackboard.max_chase_duration_seconds = _aggressive_enemy_max_chase_duration_seconds
		general_enemy_state_blackboard.chase_break_duration_seconds = _aggressive_enemy_chase_break_duration_seconds
		general_enemy_state_blackboard.attack_cooldown_seconds = _aggressive_enemy_attack_cooldown_seconds
		general_enemy_state_blackboard.attack_apply_force_magnitude = _aggressive_enemy_attack_apply_force_magnitude
		general_enemy_state_blackboard.hitstunned_push_force_magnitude = _aggressive_enemy_hitstunned_push_force_magnitude
		general_enemy_state_blackboard.hitstunned_duration_seconds = _aggressive_enemy_hitstunned_duration_seconds

	general_enemy_state_blackboard.navigation_region_3d = navigation_region_3d
	general_enemy_state_blackboard.player = get_tree().get_first_node_in_group("player")
	general_enemy_state_blackboard.player_camera_controller_3d = get_tree().get_first_node_in_group("player_camera_controller_3d")

	_detection_range_shape_cast_3d.set_scale(Vector3(_line_of_sight_range_scale, _line_of_sight_range_scale, _line_of_sight_range_scale))

	_setup_states()
	_root_state.enter_as_state_machine()

func _setup_states() -> void:
	var blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard

	var root_state: EnemyState = EmptyEnemyState.new()
	root_state.setup_init("Root", self)
	_root_state = root_state

	var play_spawn_animation_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	play_spawn_animation_state.setup_init("PlaySpawnAnimation", self)
	play_spawn_animation_state.setup_state_vars(_animation_player, blackboard.spawn_animation)
	root_state.setup_add_sub_state(play_spawn_animation_state)

	var wait_for_spawn_animation_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	wait_for_spawn_animation_state.setup_init("WaitForSpawnAnimation", self)
	wait_for_spawn_animation_state.setup_state_vars(_animation_player, blackboard.spawn_animation)
	root_state.setup_add_sub_state(wait_for_spawn_animation_state)
	root_state.setup_add_state_transition(play_spawn_animation_state, wait_for_spawn_animation_state, StateCompleteTrigger.new())

	var hitstunned_state: HitstunnableEnemyState = HitstunnableEnemyState.new()
	hitstunned_state.setup_init("HitstunnableHitstunned", self)
	root_state.setup_add_sub_state(hitstunned_state)
	root_state.setup_add_state_transition(hitstunned_state, hitstunned_state, HitstunnedTrigger.new())

	var hitstunned_receive_damage_state: ReceiveDamageEnemyState = ReceiveDamageEnemyState.new()
	hitstunned_receive_damage_state.setup_init("HitstunnedReceiveDamage", self)
	hitstunned_state.setup_add_sub_state(hitstunned_receive_damage_state)

	hitstunned_state.setup_set_forced_reentry_sub_state(hitstunned_receive_damage_state)

	var hitstunned_set_force_direction_to_player_state: SetForceDirectionToPlayerEnemyState = SetForceDirectionToPlayerEnemyState.new()
	hitstunned_set_force_direction_to_player_state.setup_init("HitstunnedSetForceDirectionToPlayer", self)
	hitstunned_set_force_direction_to_player_state.setup_state_vars(false)
	hitstunned_state.setup_add_sub_state(hitstunned_set_force_direction_to_player_state)
	hitstunned_state.setup_add_state_transition(hitstunned_receive_damage_state, hitstunned_set_force_direction_to_player_state, StateCompleteTrigger.new())

	var hitstunned_push_state: ApplyForceEnemyState = ApplyForceEnemyState.new()
	hitstunned_push_state.setup_init("HitstunnedPush", self)
	hitstunned_push_state.setup_state_vars(blackboard.hitstunned_push_force_magnitude)
	hitstunned_state.setup_add_sub_state(hitstunned_push_state)
	hitstunned_state.setup_add_state_transition(hitstunned_set_force_direction_to_player_state, hitstunned_push_state, StateCompleteTrigger.new())

	var hitstunned_check_alive_state: CheckAliveEnemyState = CheckAliveEnemyState.new()
	hitstunned_check_alive_state.setup_init("HitstunnedCheckAlive", self)
	hitstunned_state.setup_add_sub_state(hitstunned_check_alive_state)
	hitstunned_state.setup_add_state_transition(hitstunned_push_state, hitstunned_check_alive_state, StateCompleteTrigger.new())

	var hitstunned_play_hitstunned_animation_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	hitstunned_play_hitstunned_animation_state.setup_init("HitstunnedPlayHitstunnedAnimation", self)
	hitstunned_play_hitstunned_animation_state.setup_state_vars(_animation_player, blackboard.hitstunned_animation)
	hitstunned_state.setup_add_sub_state(hitstunned_play_hitstunned_animation_state)
	hitstunned_state.setup_add_state_transition(hitstunned_check_alive_state, hitstunned_play_hitstunned_animation_state, StateCompleteTrigger.new())

	var hitstunned_waiting_state: WaitForDurationEnemyState = WaitForDurationEnemyState.new()
	hitstunned_waiting_state.setup_init("HitstunnedWaiting", self)
	hitstunned_waiting_state.setup_state_vars(blackboard.hitstunned_duration_seconds)
	hitstunned_state.setup_add_sub_state(hitstunned_waiting_state)
	hitstunned_state.setup_add_state_transition(hitstunned_play_hitstunned_animation_state, hitstunned_waiting_state, StateCompleteTrigger.new())

	var hunting_state: HitstunnableEnemyState = HitstunnableEnemyState.new()
	hunting_state.setup_init("HitstunnableHunting", self)
	root_state.setup_add_sub_state(hunting_state)
	root_state.setup_add_state_transition(wait_for_spawn_animation_state, hunting_state, StateCompleteTrigger.new())
	root_state.setup_add_state_transition(hitstunned_state, hunting_state, StateCompleteTrigger.new())
	root_state.setup_add_state_transition(hunting_state, hitstunned_state, HitstunnedTrigger.new())

	var hunting_play_chase_animation_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	hunting_play_chase_animation_state.setup_init("HuntingPlayChaseAnimation", self)
	hunting_play_chase_animation_state.setup_state_vars(_animation_player, blackboard.chase_animation)
	hunting_state.setup_add_sub_state(hunting_play_chase_animation_state)

	hunting_state.setup_set_forced_reentry_sub_state(hunting_play_chase_animation_state)

	var hunting_chase_player_state: ChasePlayerEnemyState = ChasePlayerEnemyState.new()
	hunting_chase_player_state.setup_init("ChasePlayer", self)
	hunting_state.setup_add_sub_state(hunting_chase_player_state)
	hunting_state.setup_add_state_transition(hunting_play_chase_animation_state, hunting_chase_player_state, StateCompleteTrigger.new())

	var hunting_chase_face_player_state: FacePlayerEnemyState = FacePlayerEnemyState.new()
	hunting_chase_face_player_state.setup_init("ChaseFacePlayer", self)
	hunting_chase_player_state.setup_add_sub_state(hunting_chase_face_player_state)

	hunting_chase_player_state.setup_set_forced_reentry_sub_state(hunting_chase_face_player_state)

	var hunting_break_state: WaitForDurationEnemyState = WaitForDurationEnemyState.new()
	hunting_break_state.setup_init("HuntingBreak", self)
	hunting_break_state.setup_state_vars(blackboard.chase_break_duration_seconds)
	root_state.setup_add_sub_state(hunting_break_state)
	root_state.setup_add_state_transition(hunting_state, hunting_break_state, MaxChaseDurationReachedTrigger.new())
	root_state.setup_add_state_transition(hunting_break_state, hunting_state, StateCompleteTrigger.new())

	var hunting_chase_break_play_idle_animation_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	hunting_chase_break_play_idle_animation_state.setup_init("ChaseBreakPlayIdleAnimation", self)
	hunting_chase_break_play_idle_animation_state.setup_state_vars(_animation_player, blackboard.idle_animation)
	hunting_break_state.setup_add_sub_state(hunting_chase_break_play_idle_animation_state)

	hunting_break_state.setup_set_forced_reentry_sub_state(hunting_chase_break_play_idle_animation_state)

	var hunting_chase_break_face_player_state: FacePlayerEnemyState = FacePlayerEnemyState.new()
	hunting_chase_break_face_player_state.setup_init("ChaseBreakFacePlayer", self)
	hunting_break_state.setup_add_sub_state(hunting_chase_break_face_player_state)
	hunting_break_state.setup_add_state_transition(hunting_chase_break_play_idle_animation_state, hunting_chase_break_face_player_state, StateCompleteTrigger.new())

	var wait_for_attack_queue_state: WaitForAttackQueueEnemyState = WaitForAttackQueueEnemyState.new()
	wait_for_attack_queue_state.setup_init("WaitForAttackQueue", self)
	hunting_state.setup_add_sub_state(wait_for_attack_queue_state)
	hunting_state.setup_add_state_transition(hunting_chase_player_state, wait_for_attack_queue_state, PlayerReachedTrigger.new())
	hunting_state.setup_add_state_transition(wait_for_attack_queue_state, hunting_chase_player_state, EnemyFailAttackQueueTrigger.new())

	var charge_attack_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	charge_attack_state.setup_init("ChargeAttack", self)
	charge_attack_state.setup_state_vars(_animation_player, blackboard.charge_attack_animation)
	hunting_state.setup_add_sub_state(charge_attack_state)
	hunting_state.setup_add_state_transition(wait_for_attack_queue_state, charge_attack_state, EnemySuccessAttackQueueTrigger.new())

	var wait_for_charge_attack_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	wait_for_charge_attack_state.setup_init("WaitForChargeAttack", self)
	wait_for_charge_attack_state.setup_state_vars(_animation_player, blackboard.charge_attack_animation)
	hunting_state.setup_add_sub_state(wait_for_charge_attack_state)
	hunting_state.setup_add_state_transition(charge_attack_state, wait_for_charge_attack_state, StateCompleteTrigger.new())

	var set_force_direction_to_player_state: SetForceDirectionToPlayerEnemyState = SetForceDirectionToPlayerEnemyState.new()
	set_force_direction_to_player_state.setup_init("SetForceDirectionToPlayer", self)
	set_force_direction_to_player_state.setup_state_vars(true)
	hunting_state.setup_add_sub_state(set_force_direction_to_player_state)
	hunting_state.setup_add_state_transition(wait_for_charge_attack_state, set_force_direction_to_player_state, StateCompleteTrigger.new())

	var attack_face_player_state: FacePlayerEnemyState = FacePlayerEnemyState.new()
	attack_face_player_state.setup_init("AttackFacePlayer", self)
	set_force_direction_to_player_state.setup_add_sub_state(attack_face_player_state)

	var attacking_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	attacking_state.setup_init("Attacking", self)
	attacking_state.setup_state_vars(_animation_player, blackboard.attacking_animation)
	hunting_state.setup_add_sub_state(attacking_state)
	hunting_state.setup_add_state_transition(set_force_direction_to_player_state, attacking_state, StateCompleteTrigger.new())

	var attack_apply_force_state: ApplyForceEnemyState = ApplyForceEnemyState.new()
	attack_apply_force_state.setup_init("AttackApplyForce", self)
	attack_apply_force_state.setup_state_vars(blackboard.attack_apply_force_magnitude)
	hunting_state.setup_add_sub_state(attack_apply_force_state)
	hunting_state.setup_add_state_transition(attacking_state, attack_apply_force_state, StateCompleteTrigger.new())

	var attack_set_friction_state: SetFrictionEnemyState = SetFrictionEnemyState.new()
	attack_set_friction_state.setup_init("AttackSetFriction", self)
	attack_set_friction_state.setup_state_vars(_attack_friction)
	hunting_state.setup_add_sub_state(attack_set_friction_state)
	hunting_state.setup_add_state_transition(attack_apply_force_state, attack_set_friction_state, StateCompleteTrigger.new())

	var consume_attack_queue_state: ConsumeAttackQueueEnemyState = ConsumeAttackQueueEnemyState.new()
	consume_attack_queue_state.setup_init("ConsumeAttackQueue", self)
	hunting_state.setup_add_sub_state(consume_attack_queue_state)
	hunting_state.setup_add_state_transition(attack_set_friction_state, consume_attack_queue_state, StateCompleteTrigger.new())

	var wait_for_attacking_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	wait_for_attacking_state.setup_init("WaitForAttacking", self)
	wait_for_attacking_state.setup_state_vars(_animation_player, blackboard.attacking_animation)
	hunting_state.setup_add_sub_state(wait_for_attacking_state)
	hunting_state.setup_add_state_transition(consume_attack_queue_state, wait_for_attacking_state, StateCompleteTrigger.new())

	var attack_restore_friction_state: SetFrictionEnemyState = SetFrictionEnemyState.new()
	attack_restore_friction_state.setup_init("AttackRestoreFriction", self)
	attack_restore_friction_state.setup_state_vars(_default_friction)
	hunting_state.setup_add_sub_state(attack_restore_friction_state)
	hunting_state.setup_add_state_transition(wait_for_attacking_state, attack_restore_friction_state, StateCompleteTrigger.new())

	var attack_cooldown_state: WaitForDurationEnemyState = WaitForDurationEnemyState.new()
	attack_cooldown_state.setup_init("AttackCooldown", self)
	attack_cooldown_state.setup_state_vars(blackboard.attack_cooldown_seconds)
	hunting_state.setup_add_sub_state(attack_cooldown_state)
	hunting_state.setup_add_state_transition(attack_restore_friction_state, attack_cooldown_state, StateCompleteTrigger.new())
	hunting_state.setup_add_state_transition(attack_cooldown_state, hunting_play_chase_animation_state, StateCompleteTrigger.new())
	
	var dying_state: EmptyEnemyState = EmptyEnemyState.new()
	dying_state.setup_init("Dying", self)
	root_state.setup_add_sub_state(dying_state)
	root_state.setup_add_state_transition(hitstunned_state, dying_state, EnemyHealthZeroTrigger.new())

	var dying_play_death_animation_state: PlayAnimationEnemyState = PlayAnimationEnemyState.new()
	dying_play_death_animation_state.setup_init("DyingPlayDeathAnimation", self)
	dying_play_death_animation_state.setup_state_vars(_animation_player, blackboard.death_animation)
	dying_state.setup_add_sub_state(dying_play_death_animation_state)

	var dying_wait_for_death_animation_state: WaitForAnimationEnemyState = WaitForAnimationEnemyState.new()
	dying_wait_for_death_animation_state.setup_init("DyingWaitForDeathAnimation", self)
	dying_wait_for_death_animation_state.setup_state_vars(_animation_player, blackboard.death_animation)
	dying_state.setup_add_sub_state(dying_wait_for_death_animation_state)
	dying_state.setup_add_state_transition(dying_play_death_animation_state, dying_wait_for_death_animation_state, StateCompleteTrigger.new())

	var dying_create_death_particles_state: CreateDeathParticlesEnemyState = CreateDeathParticlesEnemyState.new()
	dying_create_death_particles_state.setup_init("DyingCreateDeathParticles", self)
	dying_state.setup_add_sub_state(dying_create_death_particles_state)
	dying_state.setup_add_state_transition(dying_wait_for_death_animation_state, dying_create_death_particles_state, StateCompleteTrigger.new())

	var dying_destroy_self_state: DestroySelfEnemyState = DestroySelfEnemyState.new()
	dying_destroy_self_state.setup_init("DyingDestroySelf", self)
	dying_state.setup_add_sub_state(dying_destroy_self_state)
	dying_state.setup_add_state_transition(dying_create_death_particles_state, dying_destroy_self_state, StateCompleteTrigger.new())

func get_blackboard() -> EnemyStateBlackboard:
	return _blackboard

func get_enemy_death_particles_packed_scene() -> PackedScene:
	return _enemy_death_particles_packed_scene

func get_navigation_agent_3d() -> NavigationAgent3D:
	return _navigation_agent_3d

func get_sprite_3d() -> Sprite3D:
	return _sprite_3d

func get_hit_flash_sprite_3d() -> Sprite3D:
	return _hit_flash_sprite_3d

func get_debug_label_3d() -> Label3D:
	return _debug_label_3d

func apply_hit(damage: int, knockback: Vector3) -> void:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	general_enemy_state_blackboard.receiving_damage_amount = damage
	if knockback != Vector3.ZERO:
		var dir: Vector3 = knockback
		dir.y = 0.0
		dir = dir.normalized()
		general_enemy_state_blackboard.force_direction = dir
	if _root_state != null:
		_root_state.activate_trigger(HitstunnedTrigger.new())

func get_target_position_recalculation_interval_seconds() -> float:
	return _target_position_recalculation_interval_seconds

func get_base_move_acceleration() -> float:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	return general_enemy_state_blackboard.base_move_acceleration

func get_base_desired_move_speed() -> float:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	return general_enemy_state_blackboard.base_desired_move_speed

func get_chase_player_desired_distance() -> float:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	return general_enemy_state_blackboard.chase_player_desired_distance

func get_max_chase_duration_seconds() -> float:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	return general_enemy_state_blackboard.max_chase_duration_seconds

func get_chase_break_duration_seconds() -> float:
	var general_enemy_state_blackboard: GeneralEnemyStateBlackboard = _blackboard as GeneralEnemyStateBlackboard
	return general_enemy_state_blackboard.chase_break_duration_seconds

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
	new_velocity.y -= _gravity * delta
	set_velocity(new_velocity)

	move_and_slide()

func internal_handle_death() -> void:
	var attack_manager: EnemyAttackTimingManager = EnemyAttackTimingManager.get_instance()
	if attack_manager != null:
		attack_manager.consume_enemy_from_attack_queue(self)
		attack_manager.remove_enemy(self)
	enemy_died.emit(self)
	queue_free()

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
