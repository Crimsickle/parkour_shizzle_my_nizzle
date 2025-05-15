class_name VaultComponent
extends Node2D

@export var Character : CharacterObject

@export var Enabled : bool = true

@export var WallCastLength : int = 90
@export var ObjCastLength : int = 60

@export var Y_Velo : int = 25
@export var X_Velo : int = 40

@export var AnimTime : float = 0.225
@export var HitboxTime : float = 0.3



@onready var WallCast = $WallCast
@onready var ObjCast = $ObjCast
@onready var HitboxTimer = $HitboxTimer
@onready var AnimTimer = $AnimTimer

func _ready() -> void:
	if Enabled == false:
		return
	
	Character.connect("Jump", Jump)
	HitboxTimer.connect("timeout", TimerEnded)
	AnimTimer.connect("timeout", AnimTimerEnded)
	
	Character.SetVelo("VaultVelo", Vector2.ZERO)
	
	HitboxTimer.wait_time = HitboxTime
	AnimTimer.wait_time = AnimTime

func _process(delta: float) -> void:
	if Enabled == false:
		return
	
	if Character.InputDir == 1:
		WallCast.target_position = Vector2(1, 0) * WallCastLength
		ObjCast.target_position = Vector2(1, 0) * ObjCastLength
	elif Character.InputDir == -1:
		WallCast.target_position = Vector2(1, 0) * -WallCastLength
		ObjCast.target_position = Vector2(1, 0) * -ObjCastLength
	
	Character.SetVelo("VaultVelo", Character.GetVelo("VaultVelo") * (1 - (delta * 3)))

func Jump():
	if WallCast.is_colliding() == false and ObjCast.is_colliding() == true and Character.State == "Idle" and Input.is_action_pressed("sprint") == true:
		Character.JumpScale = false
		
		Character.position = Character.position - Vector2(0, 2)
		Character.velocity = Vector2(0, -Y_Velo)
		
		Character.ChangeHitbox("VaultHitboxes")
		Character.SetVelo("VaultVelo", Vector2(Character.InputDir * X_Velo, 0))
		
		Character.ChangeState("Vaulting")
		Character.force_play_anim("vault")
		Character.AnimPlayer.speed_scale = 1
		
		HitboxTimer.start()
		AnimTimer.start()

func TimerEnded():
	Character.ChangeHitbox("IdleHitboxes")
	
	Character.JumpScale = true

func AnimTimerEnded():
	Character.ChangeState("Idle")
