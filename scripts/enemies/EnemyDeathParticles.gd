class_name EnemyDeathParticles
extends Node3D

@export var _gpu_particles_3d: GPUParticles3D

func init(enemy: Enemy) -> void:
    global_position = enemy.global_position

func play_death_particles() -> void:
    _gpu_particles_3d.emitting = true