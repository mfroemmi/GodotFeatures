extends Node3D

@export var is_player_blue: bool = true
@export_range(5, 25) var range_max: float = 10.0
@export_range(1, 10) var zoom_min: float = 5.0
@export_range(15, 30) var zoom_max: float = 20.0
@export_range(10, 45) var angle_max: float = 30.0

@export var spring_arm: SpringArm3D
@export var camera: Camera3D

var pan_speed: float = 0.01
var rotation_speed: float = 1.0

var start_zoom: float
var start_dist: float
var touch_points: Dictionary = {}
var start_angle: float
var current_angle: float

func _ready() -> void:
	spring_arm.spring_length = zoom_max * 0.75
	if not is_player_blue:
		spring_arm.rotate_y(deg_to_rad(180))

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
		
	if touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		start_dist = touch_point_positions[0].distance_to(touch_point_positions[1])
		start_zoom = spring_arm.spring_length
		start_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
	elif touch_points.size() < 2:
		start_dist = 0

func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	# Move handling
	if touch_points.size() == 1:
		var delta = event.relative
		var pan_amount = Vector3(delta.x * pan_speed, 0, delta.y * pan_speed)
		if is_player_blue:
			spring_arm.position -= pan_amount
		else:
			spring_arm.position += pan_amount
		limit_position()
			
	# Zoom, rotation
	elif touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		var current_dist = touch_point_positions[0].distance_to(touch_point_positions[1])
		var current_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		
		# Zoom handling
		var zoom_factor = current_dist / start_dist
		spring_arm.spring_length = start_zoom / zoom_factor
		limit_zoom(spring_arm.spring_length)
		
		# Rotation handling
		var new_rotation = (current_angle - start_angle) * rotation_speed
		var potential_rotation = spring_arm.rotation_degrees.y + rad_to_deg(new_rotation)
		spring_arm.rotation_degrees.y = get_limited_rotation(potential_rotation)
		start_angle = current_angle

func limit_position() -> void:
	spring_arm.position.x = clamp(spring_arm.position.x, -range_max, range_max)
	spring_arm.position.z = clamp(spring_arm.position.z, -range_max, range_max)

func limit_zoom(new_zoom: float):
	if new_zoom < zoom_min:
		spring_arm.spring_length = zoom_min
	elif new_zoom > zoom_max:
		spring_arm.spring_length = zoom_max

func get_limited_rotation(rotation: float) -> float:
	if is_player_blue:
		return clamp(rotation, -angle_max, angle_max)
	else:
		return clamp(rotation, -180 - angle_max, -180 + angle_max)

func get_angle(p1: Vector2, p2: Vector2) -> float:
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))
