class_name RollComponent
extends Node2D

@export var Character : CharacterObject

@export var GroundSlam : GroundSlamComponent

@export var RollTime : float = 0.4
@export var RollVelo : int = 25


@onready var AnimTimer = $AnimTimer

var LastInput = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Character.connect("HitFloor", HitFloor)
	
	AnimTimer.wait_time = RollTime
	AnimTimer.connect("timeout", AnimTimerEnded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Character.InputDir != 0 and Character.InputDir != LastInput:
		LastInput = Character.InputDir

func HitFloor(LastVelo):
	if LastVelo.y > 260:
		Roll()

func Roll():
	if GroundSlam.Slamming == true:
		return
	
	AnimTimer.start()

func AnimTimerEnded():
	print("yrurrrr")
