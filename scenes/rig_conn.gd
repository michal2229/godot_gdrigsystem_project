extends Node3D
@onready var rig_conn_visual_mesh: MeshInstance3D = $RigConnVisualMesh

@export var rig_node_a: Node3D
@export var rig_node_b: Node3D

@export var rest_length: float = -1
@export var stiffness := 3200.0
@export var damping := 32

@export var break_threshold := 0.25
@export var broken := false

var id = 0
func _ready() -> void:
	if rest_length == -1:
		rest_length = rig_node_a.global_position.distance_to(rig_node_b.global_position)
