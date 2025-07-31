class_name LevelNode
extends Node2D

@export var SpawnPoint : Marker2D
@export var Camera : Camera2D

func setup() -> void:
	load_character(SpawnPoint.global_position)
	
	GameCamera.register_camera(Camera)

func load_character(pos):
	var NewCharacter = LevelGlobal.current_character.CharacterScene.instantiate()
	NewCharacter.global_position = pos
	
	add_child(NewCharacter)
