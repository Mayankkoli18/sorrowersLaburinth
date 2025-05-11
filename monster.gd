extends CharacterBody3D

var speed = 3.0
var player
var JSTime = 3.0
var caught=false
signal chasingSig
@onready var env = $"../WorldEnvironment"
@onready var scream = $scream
@onready var sing = $sing
@onready var exorcism = $"../exo"
var distance :float
var chasing = false
var gravity =  ProjectSettings.get_setting("physics/3d/default_gravity")
@export var destinations : Array[Node3D]
signal uded
var encChaseOn = false
var rng
var currentDest
var canPick = false
var dolls
func _ready():
	sing.stream = preload("res://audio [vocals]_[cut_41sec].wav")
	sing.play()
	player = get_node("/root/"+get_tree().current_scene.name+"/Player")
	dolls = get_tree().get_nodes_in_group("redDoll")
	for doll in dolls:
		doll.connect("redDoll", Callable(self, "on_redDoll"))
	exorcism.connect("endGame", Callable(self, "endChase"))
	rng = RandomNumberGenerator.new()
	var randomDest = rng.randi_range(0, destinations.size()-1)
	currentDest = destinations[randomDest]

func endChase():
	encChaseOn = true
func on_redDoll():
	chasing = true
func picknewDest():
	if chasing == false && canPick == false && distance<=$NavigationAgent3D.target_desired_distance:
		canPick = true
		var wait_time = rng.randf_range(3.0, 6.0)
		if distance<=$NavigationAgent3D.target_desired_distance:
			var randomDest = rng.randi_range(0, destinations.size()-1)
			currentDest = destinations[randomDest]
			print(randomDest)
		canPick = false
func _process(delta):
	player.connect("invis", Callable(self, "invisFun"))
	if chasing == false:
		if sing.stream != preload("res://audio [vocals]_[cut_41sec].wav"):
			sing.stream = preload("res://audio [vocals]_[cut_41sec].wav")
			sing.play()
		distance = currentDest.global_transform.origin.distance_to(global_transform.origin)
		speed = 3
		update_target_location(currentDest.global_transform.origin)
	if chasing == true:
		emit_signal("chasingSig")
		if sing.stream != preload("res://sound-effect-hd_[cut_13sec]_B♭_minor__bpm_90.wav"):
			sing.stream = preload("res://sound-effect-hd_[cut_13sec]_B♭_minor__bpm_90.wav")
			sing.play()
		distance = player.global_transform.origin.distance_to(global_transform.origin)
		speed == 3
		update_target_location(player.global_transform.origin)
	if encChaseOn==true:
		while chasing == false:
			chasing= true
func invisFun():
	$RayCast3D.enabled = false
	await get_tree().create_timer(10, false).timeout
	$RayCast3D.enabled = true
func _physics_process(delta):
	if visible:
		if not is_on_floor():
			velocity.y -= gravity*delta
		var currentLoc = global_transform.origin
		var nextLock = $NavigationAgent3D.get_next_path_position()
		var newVel = (nextLock-currentLoc).normalized() * speed
		$NavigationAgent3D.set_velocity(newVel)
		var lookDir = atan2(-velocity.x, -velocity.z)
		rotation.y = lookDir
		if chasing == true:

			if distance <=1&& caught==false	:
				player.visible = false
				speed = 0
				caught = true
				$jumpScareCAm.current = true
				sing.stream = preload("res://sound-effect-hd_[cut_13sec]_B♭_minor__bpm_90.wav")
				sing.play()
				await get_tree().create_timer(JSTime, false).timeout
				emit_signal("uded")
				chasing = false
				player.visible = true
				speed = 3
				caught = false
				$jumpScareCAm.current = false
				self.global_transform.origin = Vector3(0, 1, -5)

func update_target_location(target_location):
	$NavigationAgent3D.target_position = target_location


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
