extends KinematicBody2D

export var DEFAULT_POWER : int = 10
export var SPEED : float = 0.1

var power: int = DEFAULT_POWER
var direction : Vector2 = Vector2.ZERO

onready var n_power_label := get_node("PowerLabel")

func init(i_angle: float, i_spawn_position: Vector2):
	# convert radians to vector
	direction = Vector2(cos(i_angle), sin(i_angle))
	position = i_spawn_position
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	n_power_label.text = "Power: " + str(power)

func _physics_process(delta):
	move_and_collide(direction * SPEED)
