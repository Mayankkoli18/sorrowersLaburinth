extends Node3D


@onready var dolls = $Sketchfab_Scene/dolls
@onready var player = $"../Player"
@onready var cir= $Sketchfab_Scene
@onready var door = $"../endDoor"
signal endGame
func _ready() -> void:
	player.connect("allDoll", Callable(self, "doneno"))
	$Sketchfab_Scene/Area3D.monitoring = false
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		dolls.visible = true
		emit_signal("endGame")
		if is_instance_valid(door):
			door.queue_free()
			
func doneno():
	$Sketchfab_Scene/Area3D.monitoring = true
	cir.visible = true
	
	
