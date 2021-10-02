extends Position2D

signal s_spawn_clear(instance_id)

func _on_anger_start():
	emit_signal("s_spawn_clear", get_instance_id())
