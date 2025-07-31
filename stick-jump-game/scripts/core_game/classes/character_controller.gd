class_name CharacterController
extends CharacterBody2D

signal jumped
signal jump_failed
signal start_falling
signal state_changed(new_state : GlobalEnums.CHARACTER_STATES, old_state : GlobalEnums.CHARACTER_STATES)

@export_group("Lookups")

@export var hitbox : CollisionShape2D
@export var anim_player : AnimationPlayer
@export var sprite : Sprite2D


@export_group("Physics")

@export var falling_gravity : float = 2500
@export var jumping_gravity : float = 1000

@export var jump_velocity : float = 2000
@export var jump_cutoff_threshold : float = 2000

@export var max_y : float = 2000
@export var min_y : float = -2000



@export_group("Acceleration")

@export var walk_accelerate : float = 12
@export var sprint_accelerate : float = 6
@export var air_accelerate : float = 3

@export var deceleration : float = 20

@export_group("Walking")

@export var walk_speed : float = 1000
@export var sprint_mult : float = 1.4
@export var sprint_threshold : float = 1
@export var sprint_bar_accel : float = 0.5
@export var sprint_bar_decel : float = 2


@export_group("Misc")

@export var default_cam_speed : float = 8


var gravity_enabled : bool = true
var input_enabled : bool = true
var can_move : bool = true
var jump_enabled : bool = true
var sprint_enabled : bool = true

var x_input : float = 0
var on_floor : bool = true
var jumping : bool = false
var sprinting : bool = false
var state : GlobalEnums.CHARACTER_STATES = GlobalEnums.CHARACTER_STATES.IDLE :
	set(value):
		state_changed.emit(value, state)
		state = value

var x_dir : float = 0
var sprint_num : float = 0


func jump():
	jumping = true
	velocity.y = -jump_velocity
	
	jumped.emit()


func _ready() -> void:
	LevelGlobal.character_node = self

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_axis("left", "right")
	
	if gravity_enabled:
		on_floor = false
		
		if not is_on_floor():
			for cast : RayCast2D in get_tree().get_nodes_in_group("floor_cast"):
				if cast.is_colliding():
					on_floor = true
					break
		else:
			on_floor = true
		
		if not is_on_floor():
			if jumping:
				velocity.y += jumping_gravity * delta
				
				if velocity.y >= -jump_cutoff_threshold:
					jumping = false
			else:
				velocity.y += falling_gravity * delta
		else:
			velocity.y = 0
	
	
	
	# x velocity and input #
	
	if input_enabled:
		x_input = input_dir
	
	if can_move:
		var mult : float = 0
		var dir_mult : float = 1
		
		if on_floor == false: # Air Accelerate
			mult = air_accelerate
		else:
			if x_input == 0: # Deceleration
				mult = deceleration
				
				sprint_num = move_toward(sprint_num, 0, delta * sprint_bar_decel)
			else:
				if sprinting: # Sprint Accelerate
					mult = sprint_accelerate
				else: # Walk Accelerate
					mult = walk_accelerate
		
		if sprinting:
			dir_mult = sprint_mult
		
		x_dir = lerp(x_dir, x_input * dir_mult, mult * delta)
		
		if sprint_enabled:
			if abs(sprint_num) >= 1 and abs(x_dir) >= 0.75:
				sprinting = true
			else:
				if abs(x_dir) >= sprint_threshold:
					sprint_num = move_toward(sprint_num, 1, delta * sprint_bar_accel * abs(x_dir))
				else:
					sprint_num = move_toward(sprint_num, 0, delta * sprint_bar_decel)
				
				sprinting = false
		else:
			sprinting = false
		
		velocity.x = x_dir * walk_speed
	
	
	
	# jumping #
	
	if jump_enabled:
		if jumping == false:
			var CanJump : bool = false
			
			if on_floor:
				CanJump = true
			
			if Input.is_action_just_pressed("jump"):
				if CanJump == true:
					jump()
				else:
					jump_failed.emit()
		else:
			if not Input.is_action_pressed("jump"):
				jumping = false
	else:
		if jumping == true:
			jumping = false
	
	velocity.y = clamp(velocity.y, -max_y, -min_y)
	
	move_and_slide()
