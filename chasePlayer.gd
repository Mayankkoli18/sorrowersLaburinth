extends RayCast3D

var chaseTimer := 30.0
var player

func _ready():
	player = get_node("/root/"+get_tree().current_scene.name+"/Player")
func _process(delta: float) -> void:

	if is_colliding():
		var hit = get_collider()
		if hit.name == "Player" && !get_parent().chasing:
			get_parent().update_target_location(player.global_transform.origin)
			get_parent().chasing = true
	if get_parent().chasing:
		
		chaseTimer -= delta
		if chaseTimer<=0.0:
			
			chaseTimer = 30.0
			get_parent().chasing = false
		
