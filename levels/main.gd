extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var n_start_sound := get_node("StartSound")

func _input(event):
	if event is InputEventMouseButton:
		n_start_sound.play()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label/AnimationPlayer.play("New Anim")
	$BGM.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartSound_finished():
	$BGM.stop()
	$Cover/AnimationPlayer.play("hide_scene")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://levels/level_base/level.tscn")
