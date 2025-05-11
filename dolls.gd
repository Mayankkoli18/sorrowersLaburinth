extends Area3D

signal redDoll
signal greenDoll



func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		if self.is_in_group("greenDoll"):
			emit_signal("greenDoll")
		if self.is_in_group("redDoll"):
			emit_signal("redDoll")
