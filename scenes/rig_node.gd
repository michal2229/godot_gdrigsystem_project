extends Node3D

@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var label_node: Node3D = $LabelNode
@onready var label_id: Label3D = $LabelNode/LabelId

@export var mass: float = 1.0
@export var pinned: bool = false

var velocity := Vector3.ZERO
var force := Vector3.ZERO

var stiffness = 10000
var damping = 1000

var id = -1
var cam


# Called when the node enters the scene tree for the first time.
func __ready() -> void:
	pass # Replace with function body.
	cam = get_viewport().get_camera_3d()
	label_id.text = str(id)
	label_id.visible = false
	
	#pos = global_position
	#custom_integrator = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func __process(delta: float) -> void:
	label_id.visible = true
	label_id.text = str(id)
	label_node.look_at(cam.global_position)
	
	
func _physics_process(delta: float) -> void:
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
				
			var damping_force = penetration * -relative_velocity * damping
			apply_force(collision_force + damping_force, collision_point - global_position)
			if collision_body.has_method("apply_force"):
				collision_body.apply_force(-collision_force - damping_force, collision_point - global_position)
			
			
func apply_force(f: Vector3, p: Vector3):
	force += f
