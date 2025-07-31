extends Node

var score : float = 0
var time : float = 0

var current_character : CharacterData
var character_node : CharacterController
var current_level : LevelData

func load_level(level : LevelData, character : CharacterData):
	current_character = character
	current_level = level
	
	score = 0
	time = 0
	
	SceneLoader.load_scene(current_level.Scene.resource_path)
