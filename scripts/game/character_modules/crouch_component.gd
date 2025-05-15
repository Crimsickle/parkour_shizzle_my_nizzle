class_name CrouchComponent
extends Node2D

@export var Character : CharacterObject

@onready var CrouchArea1 = $CrouchArea1
@onready var CrouchArea2 = $CrouchArea2

@onready var CheckRaycast = $Node2D/RayCast2D

var Crouching : bool = false
var Overlapping : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CrouchArea1.has_overlapping_bodies() == true and CrouchArea2.has_overlapping_bodies() == false:
		#print("yurr")
		Overlapping = true
	else:
		if CheckRaycast.is_colliding() == true:
			Overlapping = true
		else:
			Overlapping = false
	
	if Overlapping == true and (Character.State == "Idle" or Character.State == "Crouching"):
		Character.position = Character.position - Vector2(0, 0.2)
		Crouch()
	else:
		if Character.is_on_floor() == true and Character.Sprinting == false and (Character.State == "Idle" or Character.State == "Crouching"):
			if Input.is_action_just_pressed("ground_slam") == true:
				Crouch()
			elif Input.is_action_pressed("ground_slam") == false:
				UnCrouch()
		else:
			UnCrouch()
	
	if Crouching == true:
		if Character.InputDir != 0:
			Character.play_animation("crouch_walk")
		else:
			Character.play_animation("crouch_idle")


func Crouch():
	Crouching = true
	Character.ChangeHitbox("CrouchHitboxes")
	
	Character.ChangeState("Crouching")
	Character.SpeedMult = 0.5
	
	Character.AnimationsEnabled = false
	Character.Sprinting = false
	
	Character.CanMove = true
	Character.CanChangeInput = true
	Character.CanJump = false
	Character.CanSprint = false
	
	Character.SetVelo("Slide", Vector2.ZERO)

func UnCrouch():
	if Crouching == false:
		return
	
	Crouching = false
	Character.ChangeHitbox("IdleHitboxes")
	
	Character.ChangeState("Idle")
	Character.SpeedMult = 1
	
	Character.AnimationsEnabled = true
	
	Character.CanMove = true
	Character.CanChangeInput = true
	Character.CanJump = true
	Character.CanSprint = true
