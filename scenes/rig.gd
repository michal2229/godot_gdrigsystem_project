@tool
class_name Rig
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

@export var state_simulate := true
var state_cleaning := false

func va(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

func align_conn(c: RigConn):
	c.position = (c.rig_node_a.position + c.rig_node_b.position)/2
	
	c.look_at(c.rig_node_b.global_position, Vector3(0.6574416464, 0.65878165468, 0.9813563))
	c.rig_conn_visual_mesh.scale.y = c.rig_node_a.position.distance_to(c.rig_node_b.position)

func simulate(b: bool):
	state_simulate = b
	gd_rig_system.simulate(state_simulate)

func create():
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
		
		gd_rig_system.clear()
		
		for n in nodes:
			var node_obj: RigNode = RIG_NODE.instantiate()

			rig_nodes.add_child(node_obj)

			node_obj.id = n['id']
			node_obj.position = Vector3( n['pos'][0], n['pos'][1], n['pos'][2] )
			n.pos = va(node_obj.global_position)
			node_obj.mass = n['mass'] if 'mass' in n else node_defaults['mass']
			node_obj.pinned = n['pinned'] if 'pinned' in n else node_defaults['pinned']
			#node_obj.shape_cast_3d.queue_free()

			#if node_obj.position.y == 0:
			#	node_obj.pinned = true
			gd_rig_system.add_node(n, node_defaults, node_obj)

		for c in conns:
			var conn_obj = RIG_CONN.instantiate()
			
			conn_obj.id = c['id']
			conn_obj.rig_node_a = rig_nodes.get_child(c['node_a'])
			conn_obj.rig_node_b = rig_nodes.get_child(c['node_b'])
			conn_obj.stiffness = c['stiff'] if 'stiff' in c else conn_defaults['stiff']
			conn_obj.damping = c['damp'] if 'damp' in c else conn_defaults['damp']
			conn_obj.break_threshold = c['brk_thr'] if 'brk_thr' in c else conn_defaults['brk_thr']

			rig_conns.add_child(conn_obj)
			gd_rig_system.add_conn(c, conn_defaults, conn_obj)
			align_conn(conn_obj)


		visual_placeholder.visible=false
		#gd_rig_system.initialize_nodes(rig_nodes)
		#gd_rig_system.initialize_connections(rig_conns)
		if not Engine.is_editor_hint():
			gd_rig_system.simulate(state_simulate)
			gd_rig_system.visualize(true)
			
	else:
		visual_placeholder.visible=false
		rig_definition.num_levels = num_levels
		rig_definition.create()
		gd_rig_system.clear()
		gd_rig_system.initialize_nodes(rig_nodes)
		gd_rig_system.initialize_connections(rig_conns)
		for c in rig_conns.get_children():
			align_conn(c)
			
		if not Engine.is_editor_hint():
			gd_rig_system.simulate(state_simulate)
			gd_rig_system.visualize(true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if Input.is_action_just_pressed("simulate_toggle"):
		state_simulate = not state_simulate
		gd_rig_system.simulate(state_simulate)
		
	if Input.is_action_just_pressed("reset_rig_system"):
		state_cleaning = true
		gd_rig_system.simulate(false)
		gd_rig_system.visualize(false)
		gd_rig_system.clear()
		
		for c in rig_conns.get_children():
			c.queue_free()
		for n in rig_nodes.get_children():
			n.queue_free()
			
	if state_cleaning:
		if rig_conns.get_child_count() == 0 and rig_nodes.get_child_count() == 0:
			state_cleaning = false
			create()
