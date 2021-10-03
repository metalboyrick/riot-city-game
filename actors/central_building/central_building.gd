extends Area2D

signal s_mob_entered(mob_id)

func _on_CentralBuilding_body_entered(body):
	emit_signal("s_mob_entered", body.get_instance_id())
