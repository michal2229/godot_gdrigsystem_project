@tool

extends Node3D
class_name RigConn

@onready var rig_conn_visual_mesh: MeshInstance3D = $RigConnVisualMesh
@onready var label_node: Node3D = $LabelNode
@onready var label_id: Label3D = $LabelNode/LabelId

@export var rig_node_a: Node3D
@export var rig_node_b: Node3D

@export var rest_length: float = -1
@export var stiffness := 100000.0
@export var damping := 500

@export var break_threshold := 0.1
@export var broken := false

var id = -1
var cam

func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	if rest_length == -1:
		rest_length = rig_node_a.global_position.distance_to(rig_node_b.global_position)
		
func __process(delta: float) -> void:
	label_id.visible = true
	label_id.text = str(id)
	label_node.look_at(cam.global_position)
