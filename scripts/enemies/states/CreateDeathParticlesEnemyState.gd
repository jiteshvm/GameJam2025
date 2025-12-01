class_name CreateDeathParticlesEnemyState
extends EnemyState

func on_enter_state() -> void:
	var enemy_death_particles_packed_scene: PackedScene = _enemy.get_enemy_death_particles_packed_scene()
	var enemy_death_particles: EnemyDeathParticles = enemy_death_particles_packed_scene.instantiate()
	_enemy.add_sibling(enemy_death_particles)
	enemy_death_particles.init(_enemy)
	enemy_death_particles.play_death_particles()

	activate_trigger(StateCompleteTrigger.new())

func on_exit_state() -> void:
	pass

func on_process_state(delta: float) -> void:
	_enemy.get_debug_label_3d().text += "%s\n" % _state_name

func on_physics_process_state(delta: float) -> void:
	pass
