extends Node3D
@onready var visual_placeholder: MeshInstance3D = $VisualPlaceholder
@onready var rig_definition: Node = $RigDefinition

@export var num_levels: int = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visual_placeholder.visible=false
	rig_definition.num_levels = num_levels
	rig_definition.create()
	
