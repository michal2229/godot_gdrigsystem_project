extends Node3D

# A rig project to create new/load, edit, simulate, save

var state_simulating := false

	
func load_project(filename: String):
	pass
	
func save_project(filename: String):
	pass
	
func add_node(pos: Vector3):
	pass
	
func del_node(node: RigNode):
	# also delete conns it is part of
	pass
	
func add_conn(node_a: RigNode, node_b: RigNode):
	pass
	
func del_conn(conn: RigConn, del_orphan_nodes: bool = false):
	pass
	
func simulate(active: bool):
	state_simulating = active

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
