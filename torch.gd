extends OmniLight3D

var torchUI
var torchEnergy
var drainRate = 0.05

func _ready() -> void:
	torchUI = get_node("/root/"+get_tree().current_scene.name+"/UI/torchUI")
	torchEnergy = get_node("/root/"+get_tree().current_scene.name+"/UI/torchUI/torchSlider")

func _process(delta):
	if Input.is_action_just_pressed("torch") && torchEnergy.value>0:
		visible=!visible
		torchUI.visible = visible
	if visible:
		torchEnergy.value -= drainRate*delta
