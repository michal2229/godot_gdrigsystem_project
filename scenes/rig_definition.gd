extends Node

const RIG_NODE = preload("res://scenes/rig_node.tscn")
const RIG_CONN = preload("res://scenes/rig_conn.tscn")

@export var group_rignodes: Node3D
@export var group_rigconns: Node3D
@export var num_levels := 8

var connections = []

func create() -> void:
	for i in range(num_levels):
		connections += [[0 +i*4, 1 +i*4],
						#[0 +i*4, 2 +i*4],
						[0 +i*4, 3 +i*4],
						[0 +i*4, 4 +i*4],
						[0 +i*4, 5 +i*4],
						[0 +i*4, 6 +i*4],
						[0 +i*4, 7 +i*4],

						[1 +i*4, 2 +i*4],
						#[1 +i*4, 3 +i*4],
						[1 +i*4, 4 +i*4],
						[1 +i*4, 5 +i*4],
						[1 +i*4, 6 +i*4],
						[1 +i*4, 7 +i*4],

						[2 +i*4, 3 +i*4],
						[2 +i*4, 4 +i*4],
						[2 +i*4, 5 +i*4],
						[2 +i*4, 6 +i*4],
						[2 +i*4, 7 +i*4],

						[3 +i*4, 4 +i*4],
						[3 +i*4, 5 +i*4],
						[3 +i*4, 6 +i*4],
						[3 +i*4, 7 +i*4]]

	for i in range(num_levels + 1):
		for j in range(2):
			for k in range(2):
				var node_obj = RIG_NODE.instantiate()
				if (i == 0):
					#node_obj.pinned = true
					pass
				group_rignodes.add_child(node_obj)
				node_obj.position = Vector3(
					(j - 0.5) ,
					(1 + i), 
					((j ^ k) - 0.5) )

	var rng = RandomNumberGenerator.new()
	rng.seed = 32 +  num_levels
	for c in connections:
		var conn_obj = RIG_CONN.instantiate()
		conn_obj.rig_node_a = group_rignodes.get_children()[c[0]]
		conn_obj.rig_node_b = group_rignodes.get_children()[c[1]]
		conn_obj.rest_length = conn_obj.rig_node_a.global_position.distance_to(conn_obj.rig_node_b.global_position) * rng.randf_range(0.99, 1.01)
		
		group_rigconns.add_child(conn_obj)
		
