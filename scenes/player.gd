extends RigidBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") \
				* ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.0015

const accel = 25.0

var gain: float = 1000.0

var pitch: float = 0.0
var yaw: float = 0.0

var state_crouch := false
var state_fly := true

var handle_click := false
var handle_click_type : MouseButton


func _input(event):
	if (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) or event is InputEventScreenDrag:
		pitch = (pitch + -event.relative.y * mouse_sensitivity)
		yaw = (yaw + -event.relative.x * mouse_sensitivity)
		camera_3d.rotation.x = pitch

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:	
			handle_click = true
			handle_click_type = event.button_index
			pass


func _integrate_forces( state ):
	state.transform.basis = state.transform.basis.rotated(Vector3.UP, yaw)
	yaw = 0


func _physics_process(delta: float) -> void:
	if not state_fly:
		apply_central_force(gravity*mass)

		if Input.is_action_just_pressed("jump"):
			apply_central_impulse(Vector3(0,mass*10,0))

	if Input.is_action_just_pressed("crouch_press"):
		state_crouch = true
	if Input.is_action_just_released("crouch_press"):
		state_crouch = false
	if Input.is_action_just_pressed("crouch_toggle"):
		state_crouch = not state_crouch
	if Input.is_action_just_pressed("fly_toggle"):
		state_fly = not state_fly

	var local_up: Vector3 = global_transform.basis * Vector3.UP
	var error_angle: float = acos(clamp(local_up.dot(Vector3.UP), -1.0, 1.0))
	if error_angle > 0.001:
		var corrective_torque: Vector3 = local_up.cross(Vector3.UP).normalized() * error_angle * gain * mass
		apply_torque(corrective_torque)

	var input_dir_horizontal := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir_y := Input.get_vector("move_down", "move_up", "move_down", "move_up")
	var input_dir := Vector3(input_dir_horizontal.x, input_dir_y.x, input_dir_horizontal.y)

	if not state_fly:
		input_dir[1] = 0

	var direction := (transform.basis * input_dir).normalized()

	if state_fly:
		apply_central_force(direction * mass * accel * 4)
		apply_central_force(-linear_velocity * mass * 10)
	else:
		apply_force(direction * mass * accel, Vector3(0,0.5,0))
		apply_force(-linear_velocity * mass, Vector3(0,0.5,0))
		
	if handle_click:
		var mouse_pos = get_viewport().get_mouse_position()
		var start = camera_3d.project_ray_origin(mouse_pos)
		var end = start + camera_3d.project_ray_normal(mouse_pos) * 1000 # camera_3d.get_frustum()[1].d
		var space_state = get_world_3d().direct_space_state
		var rquery := PhysicsRayQueryParameters3D.create(start, end)
		rquery.collide_with_areas = true
		rquery.collide_with_bodies = false
		var result = space_state.intersect_ray( rquery )
		handle_click = false
		if result:
			var col = result['collider']
			if col is RigNode:
				#col.queue_free()
				col.selected = not col.selected
		pass
	

func is_on_floor():
	return ray_cast_3d.is_colliding()
