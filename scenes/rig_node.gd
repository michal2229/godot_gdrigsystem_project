@tool
extends Area3D
class_name RigNode


@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var label_node: Node3D = $LabelNode
@onready var label_id: Label3D = $LabelNode/LabelId

@export var mass: float = 1.0
@export var pinned: bool = false

var velocity := Vector3.ZERO
var force := Vector3.ZERO
var selected = false

var stiffness = 10000

var damping = 2000

var id = -1
var cam


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	#pos = global_position
	#custom_integrator = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		label_id.visible = true
		label_id.text = str(id)
		label_node.look_at(cam.global_position)
	else:
		label_id.visible = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not is_instance_valid(shape_cast_3d):
		return

	shape_cast_3d.force_shapecast_update()
	force = Vector3.ZERO

	if shape_cast_3d.is_colliding():
		var num_collisions = shape_cast_3d.get_collision_count()
		for i in range(num_collisions):
			var collision_body = shape_cast_3d.get_collider(i)

			if get_parent() == collision_body.get_parent().get_parent():
				continue

			var collision_point = shape_cast_3d.get_collision_point(i)
			var collision_normal = shape_cast_3d.get_collision_normal(i)
			var penetration = (shape_cast_3d.shape.radius - (collision_point - global_position).length())
			var collision_force: Vector3 = penetration * collision_normal * stiffness

			var relative_velocity = velocity
			if collision_body.has_meta("linear_velocity"):
				relative_velocity -= collision_body.linear_velocity
			var damping_force = Vector3.ZERO
			if relative_velocity.dot(collision_normal) < 0:
				damping_force = penetration * -relative_velocity * collision_normal * damping
			apply_force(collision_force + damping_force, collision_point - global_position)
			if collision_body.has_method("apply_force"):
				collision_body.apply_force(-collision_force - damping_force, collision_point - global_position)




func apply_force(f: Vector3, p: Vector3):
	force += f

