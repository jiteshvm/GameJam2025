class_name GeneralEnemyStateBlackboard
extends EnemyStateBlackboard

# Nodes
var navigation_region_3d: NavigationRegion3D = null
# Line of Sight
var player_in_line_of_sight: PlayerController3D = null
var last_known_player_position: Vector3 = Vector3.ZERO
var line_of_sight_recalculation_timer_seconds: float = 0.0
# Path Calculation
var target_position_recalculation_timer_seconds: float = 0.0
# Hunting Player
var last_viewed_player_position: Vector3 = Vector3.ZERO
# Apply Force
var force_direction: Vector3 = Vector3.ZERO