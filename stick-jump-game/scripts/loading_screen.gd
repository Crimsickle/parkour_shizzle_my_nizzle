extends Control

@onready var loading_text : Label = $LoadingText
@onready var progress_bar : ProgressBar = $ProgressBar

func _ready() -> void:
	ResourceLoader.load_threaded_request(SceneLoader.scene_location)

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(SceneLoader.scene_location, progress)
	
	loading_text.text = str(progress[0] * 100) + "%"
	progress_bar.value = progress[0] * 100
	
	if progress[0] == 1:
		var Scene = ResourceLoader.load_threaded_get(SceneLoader.scene_location)
		get_tree().change_scene_to_packed(Scene)
