extends Node2D

export var SPAWN_INTERVAL_LOW : float = 0.0
export var SPAWN_INTERVAL_HIGH : float = 5.0
export var ALLOWED_SIMULTANEOUS : int = 1
export var MONEY : int = 1000

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_spawns : Array = []
var mobs_per_lane : Array = []
var mobs_occupancy : Array  = []
var money : int = 	MONEY

onready var sc_mob := preload("res://actors/mob/mob.tscn")
onready var n_spawn_timer := get_node("SpawnTimer")
onready var n_money_label := get_node("MoneyLabel")

signal s_mob_money_ok(mob_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	assert(SPAWN_INTERVAL_LOW < SPAWN_INTERVAL_HIGH)
	
	# initialise money
	n_money_label.text = str(MONEY)
	
	# initialise mob spawners
	mob_spawns = get_tree().get_nodes_in_group("mob_spawner")
	for mob_spawn in mob_spawns:
		mob_spawn.connect("s_spawn_clear", self, "_on_spawn_clear")
		mobs_occupancy.append(false)
		mobs_per_lane.append([])
		
	assert(ALLOWED_SIMULTANEOUS <= mob_spawns.size())
		
	# initialise spawn timer
	n_spawn_timer.wait_time = rng.randf_range(SPAWN_INTERVAL_LOW, SPAWN_INTERVAL_HIGH)
	n_spawn_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(n_spawn_timer.is_stopped()):
		spawn_mob_random()
		n_spawn_timer.wait_time = rng.randf_range(SPAWN_INTERVAL_LOW, SPAWN_INTERVAL_HIGH)
		n_spawn_timer.start()
		

func spawn_mob_random():
	
	# check for number of occupied space, higher than allowed, no spawn
	var occupied_space: int = 0
	for occupancy in mobs_occupancy:
		if occupancy == true:
			occupied_space += 1
			
	if occupied_space > ALLOWED_SIMULTANEOUS - 1:
		return
	
	# check is spawner at the index is occupied
	var spawn_index : int = rng.randi_range(0, mob_spawns.size() - 1)
	if mobs_occupancy[spawn_index]:
		return 
	
	mobs_occupancy[spawn_index] = true
	var mob_spawner_instance = mob_spawns[spawn_index]
	var mob = sc_mob.instance().init(mob_spawner_instance.rotation + PI / 2, mob_spawner_instance.position)
	
	# connect the angry signal to the mob spawner
	mob.connect("s_anger_start", mob_spawner_instance, "_on_anger_start")
	mob.connect("s_mob_clicked", self, "_on_mob_clicked")
	self.connect("s_mob_money_ok", mob, "_on_money_ok")
	
	# save the mob instance
	mobs_per_lane[spawn_index].append(mob.get_instance_id())	
	add_child(mob)
	pass
	
func update_money(new_value: int):
	money = new_value
	n_money_label.text = str(money)

func _on_spawn_clear(mob_spawner_id:int):
	for i in range(mob_spawns.size()):
		if mob_spawner_id == mob_spawns[i].get_instance_id():
			mobs_occupancy[i] = false
			return
			
func _on_mob_clicked(mob_id:int):
	var mob_instance = instance_from_id(mob_id)
	
	# look for which lane it came from and clear occupancy
	var i:int = 0
	for lane in mobs_per_lane:
		if lane.find(mob_id) != -1:
			mobs_occupancy[i] = false
			lane.remove(mob_id)
			break
		i += 1
	
	if money >= mob_instance.demand_amount and !mob_instance.is_angry:
		update_money(money - mob_instance.demand_amount)
		emit_signal("s_mob_money_ok", mob_id)
		