extends Node3D

const RIG_NODE = preload("res://scenes/rig_node.tscn")
const RIG_CONN = preload("res://scenes/rig_conn.tscn")

@onready var rig_nodes: Node3D = $RigNodes
@onready var rig_conns: Node3D = $RigConns

@onready var visual_placeholder: MeshInstance3D = $VisualPlaceholder
@onready var rig_definition: Node = $RigDefinition
@onready var gd_rig_system: GDRigSystem = $GDRigSystem

@export_file("*.yaml") var yaml_rig_def: String
@export var num_levels: int = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists(yaml_rig_def):
		var file = FileAccess.open(yaml_rig_def, FileAccess.READ)
		var content = YAML.parse_string(file.get_as_text())

		var node_defaults = content['node_defaults'][0]
		var conn_defaults = content['conn_defaults'][0]
		var nodes = content['nodes']
		var conns = content['conns']

		print(node_defaults)
		print(conn_defaults)
		print(nodes[0])
		print(conns[0])

		#for n in nodes:
		#	gd_rig_system.add_node(n, node_defaults)  # TODO: also need to create a visual node and pass it

		#for c in conns:
		#	gd_rig_system.add_conn(c, conn_defaults)  # TODO: also need to create a visual conn and pass it

		for n in nodes:
			var node_obj: RigNode = RIG_NODE.instantiate()

			rig_nodes.add_child(node_obj)

			node_obj.id = n['id']
			node_obj.position = Vector3( n['pos'][0], n['pos'][1], n['pos'][2] )
			node_obj.mass = n['mass'] if 'mass' in n else node_defaults['mass']
			node_obj.pinned = n['pinned'] if 'pinned' in n else node_defaults['pinned']
			#node_obj.shape_cast_3d.queue_free()

			#if node_obj.position.y == 0:
			#	node_obj.pinned = true

		for c in conns:
			var conn_obj = RIG_CONN.instantiate()
			conn_obj.id = c['id']
			conn_obj.rig_node_a = rig_nodes.get_child(c['node_a'])
			conn_obj.rig_node_b = rig_nodes.get_child(c['node_b'])
			conn_obj.stiffness = c['stiff'] if 'stiff' in c else conn_defaults['stiff']
			conn_obj.damping = c['damp'] if 'damp' in c else conn_defaults['damp']
			conn_obj.break_threshold = c['brk_thr'] if 'brk_thr' in c else conn_defaults['brk_thr']

			rig_conns.add_child(conn_obj)


		visual_placeholder.visible=false
	else:
		visual_placeholder.visible=false
		rig_definition.num_levels = num_levels
		rig_definition.create()
