class_name GeneralEnemyStateBlackboard
extends EnemyStateBlackboard

# Nodes
var navigation_region_3d: NavigationRegion3D = null
var player: PlayerController3D = null
var player_camera_controller_3d: CameraController3D = null
# Enemy Type Animations
var spawn_animation: Animation = null
var idle_animation: Animation = null
var chase_animation: Animation = null
var charge_attack_animation: Animation = null
var attacking_animation: Animation = null
var hitstunned_animation: Animation = null
var death_animation: Animation = null
# Enemy Type Stats
var base_move_acceleration: float = 0.0
var base_desired_move_speed: float = 0.0
var chase_player_desired_distance: float = 0.0
var max_chase_duration_seconds: float = 0.0
var chase_break_duration_seconds: float = 0.0
var attack_cooldown_seconds: float = 0.0
var attack_apply_force_magnitude: float = 0.0
var attack_friction: float = 0.0
var hitstunned_push_force_magnitude: float = 0.0
var hitstunned_duration_seconds: float = 0.0
# Health
var max_health: int = 0
var current_health: int = 0
# Receiving damage
var receiving_damage_amount: int = 0
# Line of Sight
var player_in_line_of_sight: PlayerController3D = null
# Path Calculation
var target_position_recalculation_timer_seconds: float = 0.0
# Apply Force
var force_direction: Vector3 = Vector3.ZERO