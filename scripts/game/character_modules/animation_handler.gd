class_name PlayerAnimation
extends Node2D

@export var Character : CharacterObject
@export var Sprite : Sprite2D

@export var HitFloorAnimTime : float = 0.3
@export var HitFloorWalkAnimTime : float = 0.1


@export var SprintSpeed : float = 1

@export var Enabled : bool = true


@onready var HitFloorTimer = $HitFloorTimer
@onready var HitFloorWalkTimer = $HitFloorWalkTimer

func _ready() -> void:
	if Enabled == false:
		return
	
	Character.connect("HitFloor", HitFloor)
	Character.connect("Jump", Jump)
	
	HitFloorTimer.wait_time = HitFloorAnimTime
	HitFloorWalkTimer.wait_time = HitFloorWalkAnimTime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Enabled == false:
		return
	
	if Character.AnimationsEnabled == false:
		return
	
	var YVelo = Character.velocity.y
	
	Sprite.scale = Vector2(1 + (YVelo / 100 * 0.125), 1 - (YVelo / 100 * 0.125)) * 0.15
	
	if Character.State == "Idle":
		
		Character.AnimPlayer.speed_scale = 1
		
		if Character.is_on_floor():
			if abs(Character.X_Velo) > 0.1 and Character.InputDir != 0:
				if HitFloorWalkTimer.is_stopped():
					Character.play_animation("run")
					Character.AnimPlayer.speed_scale = SprintSpeed * abs(Character.X_Velo)
			else:
				if HitFloorTimer.is_stopped():
					Character.play_animation("idle")
		else:
			if Character.velocity.y >= 0:
				Character.play_animation("fall")
			else:
				pass

func HitFloor(LastVelo):
	if Character.State != "Idle":
		return
	
	if Character.AnimationsEnabled == false:
		return
	
	HitFloorTimer.start()
	HitFloorWalkTimer.start()
	
	Character.play_animation("floor_hit")

func Jump():
	if Character.State != "Idle":
		return
	
	if Character.AnimationsEnabled == false:
		return
	
	HitFloorTimer.stop()
	HitFloorWalkTimer.stop()
	
	Character.play_animation("jump")
