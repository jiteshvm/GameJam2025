class_name CollisionLayersManager
extends Node

@export var _collision_layers_definition: CollisionLayersDefinition

static var _instance: CollisionLayersManager = null

static func get_instance() -> CollisionLayersManager:
    return _instance

func _init() -> void:
    if _instance != null:
        return
    _instance = self

func get_collision_layers_definition() -> CollisionLayersDefinition:
    return _collision_layers_definition