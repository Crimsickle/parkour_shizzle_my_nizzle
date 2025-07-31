extends LevelNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	
	GameCamera.follow_character(LevelGlobal.character_node)



func _process(delta: float) -> void:
	pass
