class_name GeneralEnemyStateBlackboard
extends EnemyStateBlackboard

# Nodes
var navigation_region_3d: NavigationRegion3D = null
var player: PlayerController3D = null
var player_camera_controller_3d: CameraController3D = null
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