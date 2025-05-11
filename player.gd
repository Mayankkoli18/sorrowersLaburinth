extends CharacterBody3D

var originalSpeed =3
@export var speed = 3
@export var sprintSpeed=5
var sprintSlider
var drainAmt = 0.3
var refreshAmt = 0.4
var score = 0
var skillPoint = 2
var nightvisCount = 0
var xrayCount = 0
var invisCount = 0
signal allDoll
signal invis
signal greendoll
@export_group("headbob")
@export var headbobFreq = 2.0
@export var headbobAmp = 0.04
var headbobTime = 0.0
@onready var onsui1 =$Control/osui1
@onready var onsui2=$Control/osui2
@onready var onsui3=$Control/osui3
@onready var onsui4=$Control/CanvasLayer/osui4
@onready var onsui5=$Control/CanvasLayer/osui5
@onready var onsui6=$Control/CanvasLayer/osui6

@onready var fire = $Control/AnimatedSprite2D
@onready var bluefire = $Control/AnimatedSprite2D2
@onready var blackFire = $Control/AnimatedSprite2D3
@onready var skilltree = $Control/CanvasLayer
@onready var skillCountxt = $Control/Label2
@onready var nvButton = $Control/nvButton
@onready var xrbutton = $Control/xrButton
@onready var invisbtn = $Control/invisButton
@onready var monster=$"../Monster"
@onready var collider = $nuhuh/CollisionShape3D
@onready var foot = $AudioStreamPlayer
@onready var scoreTxt = $Control/score
@onready var wall = $"../NavigationRegion3D/Walls"
@onready var map = $Control/MiniMap
func _ready():
	speed = originalSpeed
	collider.connect("area_entered", Callable(self, "on_area_entered"))
	monster.connect("uded", Callable(self, "respawn"))
	
	sprintSlider = get_node("/root/"+get_tree().current_scene.name+"/UI/sprintSlider")
 
func respawn():
	self.global_transform.origin = Vector3(-9, 1, 25)
func on_nv_btn():
	nightvisCount+=1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$"Control/Pause menu".visible = !$"Control/Pause menu".visible
	onsui1.text = str(invisCount)
	onsui4.text = str(invisCount)
	onsui2.text = str(nightvisCount)
	onsui5.text = str(nightvisCount)
	onsui3.text = str(xrayCount)
	onsui6.text = str(xrayCount)
	skillCountxt.text = str(skillPoint)
	if Input.is_action_just_pressed("skilltree"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		skilltree.visible = !skilltree.visible
	
	if Input.is_action_just_pressed("1") && invisCount>0:
		invisCount-=1
		fire.visible = false
		bluefire.visible = false
		blackFire.visible= false
		$Control/Hand.visible = false
		emit_signal("invis")
		await get_tree().create_timer(10, false).timeout
		fire.visible = true
		$Control/Hand.visible = true
		bluefire.visible = false
		blackFire.visible= false
	if Input.is_action_just_pressed("2")&&nightvisCount>0:
		nightvisCount-=1
		
		fire.visible = false
		bluefire.visible = true
		blackFire.visible= false
		var en = $"../WorldEnvironment".environment
		en.set_tonemap_exposure(10.0)
		await get_tree().create_timer(10, false).timeout
		fire.visible = true
		bluefire.visible = false
		blackFire.visible= false
		en.set_tonemap_exposure(1.0)
	if Input.is_action_just_pressed("3")&&xrayCount>0:
		xrayCount-=1
		var text = wall.get_active_material(0)
		text.set_blend_mode(2)
		fire.visible = false
		bluefire.visible = false
		blackFire.visible= true
		await get_tree().create_timer(3, false).timeout
		text.set_blend_mode(0)
		fire.visible = true
		bluefire.visible = false
		blackFire.visible= false
	if score>=4:
		if Input.is_action_pressed("map"):
			map.visible = true
		if Input.is_action_just_released("map"):
			map.visible = false


	scoreTxt.text = str(score)
	if score == 8:
		emit_signal("allDoll")
	if speed==sprintSpeed:
		foot.pitch_scale = 0.60
		sprintSlider.value = sprintSlider.value-drainAmt*delta
		if sprintSlider.value ==sprintSlider.min_value:
			speed = originalSpeed
	if speed!=sprintSpeed:
		foot.pitch_scale = 0.44
		if sprintSlider.value <sprintSlider.max_value:
			sprintSlider.value = sprintSlider.value+refreshAmt*delta
		if sprintSlider.value == sprintSlider.max_value:
			sprintSlider.visible = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if is_on_floor():
			if not foot.playing:
				foot.play() 
		if Input.is_action_just_pressed("sprint"):
			sprintSlider.visible = true
			speed = sprintSpeed
		if Input.is_action_just_released("sprint"):
			speed = originalSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		foot.stop()

	move_and_slide()
	headbobTime+= delta*velocity.length()*float(is_on_floor())
	$head/Camera3D.transform.origin = headbob(headbobTime)

func headbob(headbobtime):
	var headbobPos = Vector3.ZERO
	headbobPos.y = sin(headbobtime*headbobFreq)*headbobAmp
	headbobPos.x = cos(headbobtime*headbobFreq/2)*headbobAmp
	return headbobPos


func _on_nuhuh_area_entered(area: Area3D) -> void:
	if area.is_in_group("greenDoll"):
		skillPoint+=1
		area.queue_free()
		emit_signal("greendoll")
		score+=1
	if area.is_in_group("redDoll"):
		skillPoint+=1
		area.queue_free()
		score+=1



func _on_night_vis_pressed() -> void:
	if skillPoint>0:
		skillPoint-=1
		nightvisCount+=1


func _on_xray_pressed() -> void:
	if skillPoint>0:
		skillPoint-=1
		xrayCount+=1



func _on_invis_pressed() -> void:
	if skillPoint>0:
		skillPoint-=1
		invisCount+=1


	


func _on_resume_btn_pressed() -> void:
	$"Control/Pause menu".visible = false


func _on_mainmenu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_end_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		get_tree().change_scene_to_file("res://end_cutscne.tscn")
