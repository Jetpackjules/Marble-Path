extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_body: AnimatableBody3D = $Rotator_Platform_Moving
@onready var label: Label3D = $Rotator_Platform_Moving/Power_Label
@onready var mesh: MeshInstance3D = $Rotator_Platform_Moving/Rotation_Platform

@export var Rotation_Speed: int = 1


func _ready():
	anim_player.speed_scale = Rotation_Speed
	label.text = str(Rotation_Speed)
	rotation = Vector3(0,0,0)
	
func spin() -> void:
	anim_player.play("Spin")


func _on_ball_detection_body_entered(body):
	spin()

func _on_ball_detection_body_exited(body):
#	anim_player.stop(false)
	pass


func _input(event):
	if mouse_over:
		if event.is_action_pressed("scroll_up"):
			anim_body.sync_to_physics = true
			Rotation_Speed += 1
			anim_player.speed_scale = Rotation_Speed
			label.text = str(Rotation_Speed)
		elif event.is_action_pressed("scroll_down"):
			Rotation_Speed -= 1
			anim_player.speed_scale = Rotation_Speed
			label.text = str(Rotation_Speed)

var mouse_over: bool = false

func _on_rotator_platform_moving_mouse_entered():
	mouse_over = true
	anim_body.sync_to_physics = true


func _on_rotator_platform_moving_mouse_exited():
	mouse_over = false


