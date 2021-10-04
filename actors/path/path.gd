extends Node2D

# TODO: migrate the mob spawn code
# TODO: send a signal to the level that contains lane ID when the deploy button is clicked

onready var mob_spawn := get_node("MobSpawn")




func _on_SafePoint_body_entered(body):
	body.queue_free()
