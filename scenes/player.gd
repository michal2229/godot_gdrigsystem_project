extends RigidBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") \
				* ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.0015

const SPEED = 5.0
const JUMP_VELOCITY = 5

var gain: float = 1000.0

var pitch: float = 0.0
var yaw: float = 0.0


func _input(event):
	if (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) or event is InputEventScreenDrag:
		pitch = (pitch + -event.relative.y * mouse_sensitivity)
		yaw = (yaw + -event.relative.x * mouse_sensitivity)
		camera_3d.rotation.x = pitch
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		if event.button_index == MOUSE_BUTTON_RIGHT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _integrate_forces( state ):
	state.transform.basis = state.transform.basis.rotated(Vector3.UP, yaw)
	yaw = 0


func _physics_process(delta: float) -> void:
	apply_central_force(gravity)
	
	var local_up: Vector3 = global_transform.basis * Vector3.UP
	var error_angle: float = acos(clamp(local_up.dot(Vector3.UP), -1.0, 1.0))
	if error_angle > 0.001:
		var corrective_torque: Vector3 = local_up.cross(Vector3.UP).normalized() * error_angle * gain * mass
		apply_torque(corrective_torque)
	
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		apply_central_impulse(Vector3(0,mass*5,0))

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		apply_force(direction * mass * 25, Vector3(0,0.5,0))
	else:
		apply_force(-linear_velocity * mass, Vector3(0,0.5,0))
		pass


func is_on_floor():
	return ray_cast_3d.is_colliding()
