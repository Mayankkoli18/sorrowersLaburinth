extends Node3D


var cam = null
@onready var front = $Front
@onready var side = $Side
@onready var back = $Back
func setCamera(c):
	cam = c
	
func _process(delta: float) -> void:
	if cam == null:
		return
	var pFWD = -cam.global_transform.basis.z
	var fwd = global_transform.basis.z
	var left = global_transform.basis.x
	var lDot = left.dot(pFWD)
	var fDot = fwd.dot(pFWD)
	if fDot< -0.85:
		front.visible = true
		side.visible = false
		back.visible = false
	elif fDot>0.85:
		front.visible = false
		side.visible = false
		back.visible = true
	elif abs(fDot)<0.3:
		front.visible = false
		side.visible = true
		back.visible = false
