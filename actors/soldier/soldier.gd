extends KinematicBody2D

export var SPEED : float = 0.1

var power: int = 0
var direction : Vector2 = Vector2.ZERO

onready var n_power_label := get_node("PowerLabel")

signal s_clash(mob_id, power_difference, mob_is_angry)

func init(i_angle: float, i_spawn_position: Vector2, i_power : int):
	# convert radians to vector
	direction = Vector2(cos(i_angle), sin(i_angle))
	position = i_spawn_position
	power = i_power
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	n_power_label.text = "Power: " + str(power)

func _physics_process(delta):
	var collision  = move_and_collide(direction * SPEED)
	if collision:
		
		# calculate power difference
		var mob_instance = instance_from_id(collision.collider_id)
		var power_difference = mob_instance.power - power
		
		# kill the mob
		var is_mob_angry : bool = mob_instance.is_angry
		if power_difference > 0:
			mob_instance.update_power(power_difference)
		else:
			mob_instance.queue_free()
			
		# send data to level
		emit_signal("s_clash", collision.collider_id,power_difference,is_mob_angry)
		
		queue_free()
