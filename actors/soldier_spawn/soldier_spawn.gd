extends Position2D

var is_cooldown : bool = false

onready var n_cooldown_timer := get_node("../CooldownTimer")
onready var n_cooldown_bar := get_node("../CooldownBar")

signal s_deploy_clicked(soldier_spawn_instance_id)

func _ready():
	n_cooldown_bar.visible = false

func _process(delta):
	n_cooldown_bar.value = 100 - ( n_cooldown_timer.time_left / n_cooldown_timer.wait_time) * 100

func _on_DeployButton_pressed():
	if !is_cooldown:
		emit_signal("s_deploy_clicked", get_instance_id())

func _on_CooldownTimer_timeout():
	is_cooldown = false
	n_cooldown_bar.visible = false
	
func _on_deploy_ok(spawner_id: int):
	if spawner_id == get_instance_id():
		n_cooldown_bar.visible = true
		n_cooldown_timer.start()
		is_cooldown = true
