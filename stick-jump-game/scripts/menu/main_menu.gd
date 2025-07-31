extends Control

@export var SelectableCharacters : Array[CharacterData]


func _on_button_button_down() -> void:
	var Level = load("res://resources/levels/base/test_level.tres")
	var Character = load("res://resources/character_config/base.tres")
	LevelGlobal.load_level(Level, Character)
