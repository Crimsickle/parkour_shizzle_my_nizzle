extends Node

var camera_speed : int = 0
var camera_pos : Vector2 = Vector2.ZERO
var camera_character : CharacterController

var shake_data : Dictionary = {}
var shake_id : int = 0

var registered_camera : Camera2D = null
var pos_point : Marker2D = null

var camera_enabled : bool = true

func follow_character(follow_node : CharacterController):
	if !registered_camera:
		return
	
	var speed = follow_node.default_cam_speed
	
	if speed and speed > 0:
		registered_camera.position_smoothing_enabled = true
		registered_camera.position_smoothing_speed = speed
	else:
		registered_camera.position_smoothing_enabled = false
	
	camera_pos = Vector2.ZERO
	camera_character = follow_node

func force_position(pos : Vector2, fade_in : float, fade_out : float):
	pass





func shake_camera(fade_in : float, fade_out : float, roughness : float, vector : Vector2, mult : float):
	shake_id += 1
	
	var curr_id = shake_id
	
	shake_data[curr_id] = {
		"fade_in" : fade_in,
		"fade_out" : fade_out,
		"total_time" : fade_in + fade_out,
		
		"timer" : get_tree().create_timer(fade_in + fade_out),
		
		"roughness" : roughness,
		"vector" : vector,
		"mult" : mult,
		
		"curr_vector" : Vector2.ZERO
	}
	
	await get_tree().create_timer(fade_in + fade_out).timeout
	
	shake_data.erase(curr_id)




func cleanup():
	if pos_point:
		pos_point.queue_free()
		pos_point = null

func register_camera(camera : Camera2D):
	cleanup()
	
	registered_camera = camera
	
	var new_pos_point = Marker2D.new()
	pos_point = new_pos_point
	get_tree().get_root().add_child(new_pos_point)



func _process(delta: float) -> void:
	if registered_camera == null:
		cleanup()
		
		return
	
	if camera_enabled == false:
		return
	
	if camera_character:
		pos_point.global_position = camera_character.global_position
	
	var shake_offset : Vector2 = Vector2.ZERO
	
	for key in shake_data:
		var data = shake_data[key]
		var shake_mult : float = 0
		var curr_time = -(data.timer.time_left - data.total_time)
		
		if curr_time <= data.fade_in:
			shake_mult = curr_time / data.fade_in
		else:
			shake_mult = (curr_time - data.fade_in) / data.fade_out
			shake_mult = -shake_mult + 1
		
		var shake_vec = data.curr_vector.move_toward(
			Vector2(
				randf_range(-1, 1),
				randf_range(-1, 1)
			) * data.vector,
			data.roughness * delta
		) * shake_mult * data.mult
		
		shake_offset += shake_vec
		
		print(shake_mult)
	
	registered_camera.offset = Vector2.ZERO + shake_offset
	registered_camera.global_position = pos_point.global_position
