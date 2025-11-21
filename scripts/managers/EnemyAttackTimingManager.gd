class_name EnemyAttackTimingManager
extends Node

@export var _enemy_attack_queue_hold_duration_seconds: float = 0.5

var _enemies: Array[Enemy] = []
var _enemy_attack_queue: Array[EnemyAttackQueueEntry] = []

static var _instance: EnemyAttackTimingManager = null

static func get_instance() -> EnemyAttackTimingManager:
	return _instance

func _init() -> void:
	if _instance != null:
		return
	_instance = self

func add_enemy(enemy: Enemy) -> void:
	_enemies.append(enemy)

func remove_enemy(enemy: Enemy) -> void:
	_enemies.erase(enemy)

func add_enemy_to_attack_queue(enemy: Enemy) -> void:
	var enemy_attack_queue_entry: EnemyAttackQueueEntry = EnemyAttackQueueEntry.new()
	enemy_attack_queue_entry.init(enemy, _enemy_attack_queue_hold_duration_seconds)
	_enemy_attack_queue.append(enemy_attack_queue_entry)

func is_enemy_still_in_attack_queue(enemy: Enemy) -> bool:
	for enemy_attack_queue_entry: EnemyAttackQueueEntry in _enemy_attack_queue:
		if enemy_attack_queue_entry.get_enemy() == enemy:
			return true
	return false

func is_enemy_next_in_attack_queue(enemy: Enemy) -> bool:
	var enemy_attack_queue_entry: EnemyAttackQueueEntry = _enemy_attack_queue.front()
	return enemy_attack_queue_entry.get_enemy() == enemy

func consume_enemy_from_attack_queue(enemy: Enemy) -> void:
	_remove_enemy_from_attack_queue(enemy)

func _process(delta: float) -> void:
	for enemy_attack_queue_entry: EnemyAttackQueueEntry in _enemy_attack_queue:
		enemy_attack_queue_entry.set_hold_duration_remaining_seconds(enemy_attack_queue_entry.get_hold_duration_remaining_seconds() - delta)
		if enemy_attack_queue_entry.get_hold_duration_remaining_seconds() <= 0.0:
			consume_enemy_from_attack_queue(enemy_attack_queue_entry.get_enemy())

func _remove_enemy_from_attack_queue(enemy: Enemy) -> void:
	for enemy_attack_queue_entry: EnemyAttackQueueEntry in _enemy_attack_queue:
		if enemy_attack_queue_entry.get_enemy() == enemy:
			_enemy_attack_queue.erase(enemy_attack_queue_entry)
			break

class EnemyAttackQueueEntry:
	var _enemy: Enemy
	var _hold_duration_remaining_seconds: float = 0.0

	func init(enemy: Enemy, hold_duration_seconds: float) -> void:
		_enemy = enemy
		_hold_duration_remaining_seconds = hold_duration_seconds
	
	func get_enemy() -> Enemy:
		return _enemy
	
	func get_hold_duration_remaining_seconds() -> float:
		return _hold_duration_remaining_seconds

	func set_hold_duration_remaining_seconds(hold_duration_remaining_seconds: float) -> void:
		_hold_duration_remaining_seconds = hold_duration_remaining_seconds
