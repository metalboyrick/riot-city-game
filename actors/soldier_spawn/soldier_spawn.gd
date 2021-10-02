extends Position2D

signal s_deploy_clicked(soldier_spawn_instance_id)

func _on_DeployButton_pressed():
	emit_signal("s_deploy_clicked", get_instance_id())
