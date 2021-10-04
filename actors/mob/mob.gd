extends KinematicBody2D

# constants (editable)
export var SPEED : float = 10
export var DEFAULT_CALM : float = 3

# global variables
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var calm_time : float = DEFAULT_CALM
var is_angry : bool = false
var direction : Vector2 = Vector2.ZERO
var demand_amount : int = 0
var power : int = 0

# select all the necessary child nodes
onready var n_calm_timer := get_node("CalmTimer")
onready var n_calm_bar := get_node("CalmBar")
onready var n_demand_label := get_node("DemandLabel")
onready var n_power_label := get_node("PowerLabel")
onready var n_sprite := get_node("AnimatedSprite")

# signals
signal s_anger_start
signal s_mob_clicked(instance_id)

# "constructor"
# direction in radians
func init(i_angle: float, i_spawn_position: Vector2, i_calm_time: float):
	# convert radians to vector
	direction = Vector2(cos(i_angle), sin(i_angle))
	position = i_spawn_position
	if i_calm_time == 0:
		is_angry = true
	calm_time = i_calm_time
	return self

func _ready():
	# don't let control-type nodes consume input
	n_calm_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	n_demand_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	n_power_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	rng.randomize()
	input_pickable = true
	
	demand_amount = floor(rng.randi_range(1, 6) * 100)
	power = floor(rng.randi_range(1,5) * 10)
	
	if !is_angry:
		n_calm_timer.wait_time = calm_time
		n_calm_timer.start()
		n_demand_label.text = "Price: " + str(demand_amount)
	else:
		n_demand_label.text = "!"
		modulate = Color(1,0,0)
		emit_signal("s_anger_start")
	n_power_label.text = "Power: " +  str(power)
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed && !is_angry:
			emit_signal("s_mob_clicked", get_instance_id())

func _physics_process(delta):
	# calculate progress bar value and display
	if !is_angry:
		var calm_percent : float = 100.0 - (n_calm_timer.time_left/calm_time) * 100.0
		n_calm_bar.value = calm_percent
		
	if n_calm_timer.time_left == 0:
		if n_calm_bar.visible:
			n_calm_bar.visible = false
			n_demand_label.text = "!"
			is_angry = true
			n_sprite.animation = "angry"
			emit_signal("s_anger_start")
			
		move_and_collide(direction * SPEED)

func update_power(new_value: int):
	power = new_value
	n_power_label.text = "Power: " +  str(power)

func _on_money_ok(mob_id:int):
	if mob_id == get_instance_id():
		queue_free()
