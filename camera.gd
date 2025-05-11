extends Node3D
var sens = 0.005

# Shake parameters
var shake_intensity : float = 0.0
var shake_duration : float = 0.0
var shake_timer : float = 0.0

# Original position and rotation
var original_position : Vector3
var original_rotation : Vector3

var monster
func _ready():
	monster = get_node("/root/"+get_tree().current_scene.name+"/Monster")
	get_tree().call_group("monster", "setCamera", self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	monster.connect("chasingSig", Callable(self, "triggershAKE"))

func _input(event:InputEvent)-> void:
	if event.is_action_pressed("lock"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * sens)
		rotate_x(-event.relative.y*sens)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
