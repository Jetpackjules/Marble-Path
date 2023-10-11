extends Node3D

var marble = preload("res://marble.tscn")


func _input(event):
	if event.is_action_pressed("spawn_marble"):
		var marble_instance = marble.instantiate()
		get_tree().get_root().add_child(marble_instance)
		marble_instance.global_position = global_position

