extends Node2D

export var SPAWN_INTERVAL_LOW : float = 0.0
export var SPAWN_INTERVAL_HIGH : float = 5.0
export var MONEY : int = 1000

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_spawns : Array = []
var mobs : Array = []
var mobs_occupancy : Array  = []
var money : int = 	MONEY

onready var sc_mob = preload("res://actors/mob/mob.tscn")
onready var n_spawn_timer = get_node("SpawnTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(SPAWN_INTERVAL_LOW < SPAWN_INTERVAL_HIGH)
	
	# initialise mob spawners
	mob_spawns = get_tree().get_nodes_in_group("mob_spawner")
	for mob_spawn in mob_spawns:
		mob_spawn.connect("s_spawn_clear", self, "_on_spawn_clear")
		mobs_occupancy.append(false)
		
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
	var spawn_index : int = rng.randi_range(0, mob_spawns.size() - 1)
	if mobs_occupancy[spawn_index]:
		return 
	mobs_occupancy[spawn_index] = true
	var mob_spawner_instance = mob_spawns[spawn_index]
	var mob = sc_mob.instance().init(mob_spawner_instance.rotation + PI / 2, mob_spawner_instance.position)
	
	# connect the angry signal to the mob spawner
	mob.connect("s_anger_start", mob_spawner_instance, "_on_anger_start")
	
	# save the mob instance
	mobs.append(mob)	
	add_child(mob)
	pass

func _on_spawn_clear(mob_spawner_id:int):
	for i in range(mob_spawns.size()):
		if mob_spawner_id == mob_spawns[i].get_instance_id():
			mobs_occupancy[i] = false
			return
