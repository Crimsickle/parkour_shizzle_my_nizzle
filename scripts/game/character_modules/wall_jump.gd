class_name WallKickComponent
extends Node2D

@export var Character : CharacterObject

@export var JumpVelo : int = 100
@export var KickLength : int = 50
@export var AnimLength : float = 1.5
@export var BufferTime : float = 0.2
@export var StoreTime : float = 0.5

@export var Enabled : bool = true

@onready var WallCast = $WallCast
@onready var WallCast2 = $WallCast2
@onready var AnimTimer = $AnimTimer
@onready var StoreTimer = $StoreTimer


func _ready() -> void:
	if Enabled == false:
		return
	
	AnimTimer.wait_time = AnimLength
	StoreTimer.wait_time = StoreTime
	
	Character.connect("HitFloor", HitFloor)
	StoreTimer.connect("timeout", StoreTimerEnded)

var Backflipping = false
var LastDir = 0



var JumpTick = 0
var HoldingJump = false
var Backflipped = false

var StartDir = 0

func _process(delta: float) -> void:
	if Enabled == false:
		return
	
	if Character.InputDir == 1:
		WallCast.target_position = Vector2(1, 0) * -KickLength
		WallCast2.target_position = Vector2(-1, 0) * -KickLength
	elif Character.InputDir == -1:
		WallCast.target_position = Vector2(1, 0) * KickLength
		WallCast2.target_position = Vector2(-1, 0) * KickLength
	
	var CurrTick = float(Time.get_ticks_msec()) / 1000
	
	if Input.is_action_just_pressed("jump"):
		HoldingJump = true
		JumpTick = CurrTick
		
		StartDir = Character.InputDir
	
	if Input.is_action_just_released("jump"):
		HoldingJump = false
	
	if Input.is_action_pressed("jump"):
		var Colliding = false
		
		if WallCast.is_colliding():
			Colliding = true
		elif WallCast2.is_colliding():
			Colliding = true
		
		if Colliding == true and HoldingJump == true and (CurrTick - JumpTick) <= BufferTime:
			if StartDir == 0:
				StartDir = Character.InputDir
			
			if Character.is_on_floor():
				return
			
			if StartDir == LastDir:
				return
			
			if Character.velocity.y < -25 or Character.velocity.y > 25:
				return
			
			if Character.State != "Idle":
				return
			
			if Backflipped == true:
				return
			print("yurrr", Character.State)
			
			LastDir = StartDir
			
			AnimTimer.stop()
			AnimTimer.start()
			
			Backflipped = true
			Backflipping = true
			Character.State = "Backflipping"
			
			Character.force_play_anim("wall_kick")
			
			Character.velocity.y = -JumpVelo
	
	if (CurrTick - JumpTick) <= BufferTime and HoldingJump == true:
		HoldingJump = false
	
	if (Character.is_on_floor() or AnimTimer.is_stopped() == true) and Character.State == "Backflipping":
		Backflipping = false
		Character.State = "Idle"
		

func HitFloor(LastVelo):
	if Backflipped == true and LastVelo.y > 60:
		Character.StoredType = "WallKick"
		Character.StoredVelo = LastVelo.distance_to(Vector2.ZERO)
	
	Backflipped = false
	LastDir = 0

func StoreTimerEnded():
	if Character.StoredType == "WallKick":
		Character.StoredType = ""
		Character.StoredVelo = 0
