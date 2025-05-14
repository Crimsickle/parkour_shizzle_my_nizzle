class_name SlidingComponent
extends Node2D

@export var Character : CharacterObject

@export var SlideVelo : int = 50
@export var SlideJumpVelo : float = 100

@export var SlideDebounce : float = 1

@onready var DebounceTimer = $DebounceTimer
@onready var SlideAnimTimer = $SlideAnimTimer
@onready var SlideJumpAnimTimer = $SlideJumpAnimTimer

@onready var Sprite = Character.get_node("Sprite2D")

var SlideDir = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Character.SetVelo("Slide", Vector2.ZERO)
	Character.SetVelo("SlideJump", Vector2.ZERO)
	
	Character.connect("Jump", Jump)
	Character.connect("HitFloor", HitFloor)
	
	SlideAnimTimer.connect("timeout", SlideTimerEnd)
	SlideJumpAnimTimer.connect("timeout", SlideJumpTimerEnd)
	
	DebounceTimer.wait_time = SlideDebounce


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ground_slam") and Character.InputDir != 0 and DebounceTimer.is_stopped() == true:
		if Character.is_on_floor() and abs(Character.X_Velo) > 0.5 and Input.is_action_pressed("sprint") == true:
			StartSliding(Character.InputDir)
	
	if Input.is_action_just_released("ground_slam") and Character.State == "Sliding":
		StopSliding()
		
		SlideDir = 0
	
	if Character.State == "Sliding":
		Character.SetVelo("Slide", Character.GetVelo("Slide") * (1 - (delta * 0.65)))
		
		if Character.GetVelo("Slide").distance_to(Vector2.ZERO) < 60:
			Character.CanJump = false
	else:
		Character.SetVelo("Slide", Character.GetVelo("Slide") * (1 - (delta * 3)))
	
	if Character.State == "SlideJump":
		if Sprite.flip_h:
			Sprite.rotation = deg_to_rad(Character.velocity.y * -0.2)
		else:
			Sprite.rotation = deg_to_rad(Character.velocity.y * 0.2)
	
	if Character.is_on_floor():
		Character.SetVelo("SlideJump", Character.GetVelo("SlideJump") * (1 - (delta * 10)))
	else:
		Character.SetVelo("SlideJump", Character.GetVelo("SlideJump") * (1 - (delta * 1.5)))

func StartSliding(Dir):
	if Character.State == "Crouching":
		return
	
	Character.State = "Sliding"
	
	Character.CanMove = false
	Character.CanChangeInput = false
	Character.CanJump = true
	Character.CanSprint = false
	Character.AnimationsEnabled = false
	
	Character.X_Velo = 0
	
	SlideDir = Character.InputDir
	
	if Character.StoredType == "WallKick":
		Character.SetVelo("Slide", Vector2((SlideVelo + (Character.StoredVelo / 3)) * Character.InputDir, 0))
		
		Character.StoredType = ""
		Character.StoredVelo = 0
	else:
		Character.SetVelo("Slide", Vector2(SlideVelo * Character.InputDir, 0))
	
	SlideAnimTimer.start()
	Character.force_play_anim("slide_start")
	
	Character.ChangeHitbox("SlideHitboxes")

func StopSliding():
	DebounceTimer.start()
	
	Character.State = "Idle"
	
	Character.CanMove = true
	Character.CanChangeInput = true
	Character.CanJump = true
	Character.CanSprint = true
	Character.AnimationsEnabled = true
	
	Character.ChangeHitbox("IdleHitboxes")
	
	print("yoooo")

func Jump():
	if Character.State != "Sliding":
		return
	
	var CurrVelo : float = Character.GetVelo("Slide").distance_to(Vector2.ZERO)
	var CurrMult : float = Character.GetVelo("Slide").distance_to(Vector2.ZERO) / SlideVelo
	CurrMult = clamp(floor((CurrMult * 10) + 0.5) / 10, 0.5, 1.2)
	
	if CurrVelo < 60:
		return
	
	print(CurrMult)
	
	StopSliding()
	
	Character.CanMove = false
	Character.CanChangeInput = false
	Character.CanJump = false
	Character.CanSprint = false
	Character.AnimationsEnabled = false
	
	Character.SetVelo("Slide", Vector2.ZERO)
	Character.SetVelo("SlideJump", Vector2(SlideJumpVelo * SlideDir * CurrMult, 0))
	
	Character.velocity.y = -70 * CurrMult
	
	Character.State = "SlideJump"
	Character.force_play_anim("long_jump_start")
	SlideJumpAnimTimer.start()

func HitFloor(_LastVelo):
	if Character.State != "SlideJump":
		return
	
	Character.State = "Idle"
	
	Character.CanMove = true
	Character.CanChangeInput = true
	Character.CanJump = true
	Character.CanSprint = true
	Character.AnimationsEnabled = true
	
	Sprite.rotation = deg_to_rad(0)

func SlideTimerEnd():
	Character.force_play_anim("slide")

func SlideJumpTimerEnd():
	Character.force_play_anim("long_jump")
