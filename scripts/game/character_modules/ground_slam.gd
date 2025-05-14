class_name GroundSlamComponent
extends Node2D

@export var Character : CharacterObject

@export var SlamVelo : int = 250
@export var SlamJumpVelo : int = 100

@export var SlamJumpBuffer : float = 0.15
@export var SlamJumpCooldown : float = 0.5

@export var Enabled : bool = true

@onready var JumpTimer = $JumpTimer
@onready var SlamJumpTimer = $SlamJumpTimer

var Slamming = false
var SuperJump = false

func _ready() -> void:
	Character.connect("HitFloor", HitFloor)
	Character.connect("Jump", Jump)
	
	JumpTimer.connect("timeout", TimerEnd)
	
	JumpTimer.wait_time = SlamJumpBuffer
	SlamJumpTimer.wait_time = SlamJumpCooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Enabled == false:
		return
	
	if Input.is_action_just_pressed("ground_slam") and Character.State == "Idle" and Character.is_on_floor() == false:
		if Character.velocity.y > -50:
			Character.velocity.y = SlamVelo
			Slamming = true

func HitFloor(LastVelo):
	if Character.State != "Idle":
		return
	
	JumpTimer.start()
	
	if SuperJump == true:
		Character.JumpScale = true
		SuperJump = false

func Jump():
	if JumpTimer.is_stopped() == false and Slamming == true and SlamJumpTimer.is_stopped() == true:
		if Character.State != "Idle":
			return
		
		Character.JumpScale = false
		Character.velocity.y = -SlamJumpVelo
		SlamJumpTimer.start()
		
		SuperJump = true

func TimerEnd():
	Slamming = false
