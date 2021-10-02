extends KinematicBody2D

# constants (editable)
export var SPEED : float = 10
export var DEFAULT_CALM : float = 3

# global variables
var calm_time : float = DEFAULT_CALM
var direction : Vector2 = Vector2.ZERO

# select all the necessary child nodes
onready var n_calm_timer := get_node("CalmTimer")
onready var n_calm_bar := get_node("CalmBar")

# signals
signal s_anger_start

# "constructor"
# direction in radians
func init(i_angle: float, i_spawn_position: Vector2):
	# convert radians to vector
	direction = Vector2(cos(i_angle), sin(i_angle))
	position = i_spawn_position
	return self

func _ready():
	n_calm_timer.wait_time = calm_time
	n_calm_timer.start()
	

func _process(delta):
	# calculate progress bar value and display
	var calm_percent : float = 100.0 - (n_calm_timer.time_left/calm_time) * 100.0
	n_calm_bar.value = calm_percent
	
	if n_calm_timer.time_left == 0:
		if n_calm_bar.visible:
			n_calm_bar.visible = false
			modulate = Color(1,0,0)
			emit_signal("s_anger_start")
			
		move_and_collide(direction * SPEED)
