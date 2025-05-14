class_name CharacterObject
extends CharacterBody2D

signal Jump
signal HitFloor
signal StartFalling
signal StartMoving

@export_category("Basic Stats")

@export var Speed : int = 10
@export var JumpHeight : float = 20
@export var Gravity : float = 30

@export var SprintMult : float = 1.5

@export var JumpTime : float = 0.5

@export_category("Acceleration")

@export var AccelerationSpeed : float = 5
@export var SprintAccelerationSpeed : float = 5
@export var DecelerationSpeed : float = 10

@export_category("Sprite")

@export var SpriteTexture : CompressedTexture2D
@export var HorizontalFrames : int = 1
@export var VerticalFrames : int = 1


@onready var Camera = $Camera2D
@onready var AnimPlayer = $AnimationPlayer
@onready var Sprite = $Sprite2D

var Velocities = {}

var HitboxGroups = [
	"DiveHitboxes",
	"IdleHitboxes",
	"SlideHitboxes",
	"VaultHitboxes",
	"CrouchHitboxes",
]

func SetVelo(Name, Velo):
	Velocities[Name] = Velo

func GetVelo(Name):
	if Velocities[Name] == null:
		SetVelo(Name, Vector2(0, 0))
	
	return Velocities[Name]

func AddVelo(Name, Velo):
	if GetVelo(Name) == null:
		SetVelo(Name, Velo)
	
	Velocities[Name] += Velo

func ChangeHitbox(Name):
	for groupname in HitboxGroups:
		var Nodes = get_tree().get_nodes_in_group(groupname)
		
		for Hitbox in Nodes:
			if groupname == Name:
				Hitbox.disabled = false
			else:
				Hitbox.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ChangeHitbox("IdleHitboxes")

var TouchingGround : bool = false

var Jumped : bool = false
var Jumping : bool = false
var JumpNum : float = 0

var JumpScale : bool = true

var InputDir : float = 0
var CurrAnim : String = "idle"
var State : String = "Idle"

var CanMove : bool = true
var CanChangeInput : bool = true
var CanJump : bool = true
var CanSprint : bool = true

var SpeedMult : float = 1
var AnimationsEnabled : bool = true

var Sprinting : bool = false

var StoredVelo : float = 0
var StoredType : String = ""

var LastVelo : Vector2 = Vector2.ZERO

var X_Velo : float = 0

func JumpFunc():
	if Jumped == true:
		return
	
	if not is_on_floor():
		return
	
	if CanJump == false:
		return
	
	Jumped = true
	Jumping = true
	
	velocity.y = -JumpHeight
	
	Jump.emit()

func HitFloorFunc(LastVelo):
	HitFloor.emit(LastVelo)

func StartFallingFunc():
	StartFalling.emit()

func StartMovingFunc():
	StartMoving.emit()

func StopMovingFunc():
	StartMoving.emit()

func play_animation(anim_name):
	if AnimPlayer.current_animation == anim_name:
		return
	
	AnimPlayer.play(anim_name)
	CurrAnim = anim_name

func force_play_anim(anim_name):
	if AnimPlayer.current_animation == anim_name:
		AnimPlayer.stop()
	
	AnimPlayer.play(anim_name)
	CurrAnim = anim_name

func clampinterpolate(a, b, t): return a * (1 - clamp(t, 0, 1)) + b * clamp(t, 0, 1)

func _process(delta: float) -> void:
	if is_on_floor() != TouchingGround:
		TouchingGround = is_on_floor()
		if TouchingGround == true:
			Jumped = false
			
			HitFloorFunc(LastVelo)
	
	if CanChangeInput == true:
		var input_dir := Input.get_axis("a", "d")
		
		if InputDir == 0 and input_dir != 0:
			StartMovingFunc()
		elif InputDir != 0 and input_dir == 0:
			StopMovingFunc()
		
		InputDir = input_dir
		
		if Input.is_action_pressed("a"):
			Sprite.flip_h = true
		elif Input.is_action_pressed("d"):
			Sprite.flip_h = false
	else:
		InputDir = 0
	
	if not is_on_floor():
		velocity.y += (Gravity * delta)
	else:
		velocity.y = 0
		JumpNum = 0
	
	if CanMove == true:
		if InputDir == 0:
			X_Velo = clampinterpolate(X_Velo, InputDir, delta * DecelerationSpeed)
		else:
			if Input.is_action_pressed("sprint") and CanSprint == true:
				Sprinting = true
				X_Velo = clampinterpolate(X_Velo, InputDir * SprintMult, delta * SprintAccelerationSpeed)
			else:
				Sprinting = false
				X_Velo = clampinterpolate(X_Velo, InputDir, delta * AccelerationSpeed)
	else:
		X_Velo = 0
	
	velocity.x = X_Velo * Speed * SpeedMult
	
	if Input.is_action_just_pressed("jump") and CanJump == true:
		JumpFunc()
	
	if Input.is_action_pressed("jump") == false and Jumping == true:
		Jumping = false
	
	if Jumping == true and JumpNum >= JumpTime:
		Jumping = false
	
	if Jumping == true and JumpScale == true:
		var Mult : float = -((JumpNum / JumpTime) / 2) + 1
		velocity.y = -JumpHeight * Mult
		JumpNum = JumpNum + delta
	
	for VeloName in Velocities:
		velocity = velocity + GetVelo(VeloName)
	
	if LastVelo.y <= 0 and velocity.y > 0:
		StartFallingFunc()
	
	LastVelo = velocity
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
