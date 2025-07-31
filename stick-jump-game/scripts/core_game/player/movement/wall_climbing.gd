extends Node2D



@export_group("Ability List")

@export var wall_climbing : bool = true
@export var wall_jumping : bool = true
@export var wall_kicking : bool = true



@export_group("Cast Lengths")

@export var wall_cast_length : float = 75
@export var back_cast_length : float = 55



@export_group("Wall Jumping")

@export var same_wall_punishment : float = 30 :
	get:
		return same_wall_punishment / 100



@export_group("Velocity Stuffs")

@export var velocity_threshold : float = -100



@export_group("State Names")

@export var wall_climb_state : GlobalEnums.CHARACTER_STATES
@export var wall_kick_state : GlobalEnums.CHARACTER_STATES

# ------------------------------------------------- #

@onready var character : CharacterController = LevelGlobal.character_node

@onready var wall_cast : RayCast2D = $WallCast
@onready var back_cast : RayCast2D = $BackCast

var hugging_wall : bool = false

var current_normal : Vector2 = Vector2.ZERO
var last_normal : Vector2 = Vector2.ZERO
var boost_mult : float = 1

func start_wall_climb():
	pass

func update_wall_climb():
	if character.state != wall_climb_state:
		pass

func stop_wall_climb():
	pass

func wall_jump(normal : Vector2):
	if normal == last_normal:
		boost_mult = boost_mult - same_wall_punishment
	
	last_normal = normal
	
	print("thruth poop")

func wall_kick(normal : Vector2):
	pass



func can_climb(normal : Vector2):
	return (normal == Vector2(1, 0) or normal == Vector2(-1, 0))


func _process(delta: float) -> void:
	if character == null:
		if LevelGlobal.character_node:
			character = LevelGlobal.character_node
		
		return
	
	var touching_wall : bool = false
	
	if wall_climbing:
		if character.x_input == 0:
			return
		
		wall_cast.target_position = Vector2(wall_cast_length * character.x_input, 0)
		back_cast.target_position = Vector2(back_cast_length * -character.x_input, 0)
		
		wall_cast.force_raycast_update()
		back_cast.force_raycast_update()
		
		if character.state == GlobalEnums.CHARACTER_STATES.IDLE:
			if character.velocity.y >= velocity_threshold and not character.is_on_floor():
				$ColorRect.color = Color8(0, 255, 0)
				
				if wall_cast.is_colliding():
					pass
				else:
					if back_cast.is_colliding():
						if Input.is_action_just_pressed("jump"):
							if boost_mult >= 0.1 and can_climb(back_cast.get_collision_normal()) == true:
								wall_jump(back_cast.get_collision_normal())
			else:
				$ColorRect.color = Color8(255, 0, 0)
		elif character.state == wall_climb_state:
			update_wall_climb()
