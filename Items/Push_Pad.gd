extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var push_pad: AnimatableBody3D = $Push_Pad_Moving
@onready var label: Label3D = $Push_Pad_Moving/Power_Label
#@onready var mesh: MeshInstance3D = $Push_Pad_Moving/Bounce_Pad

@export var Push_Speed: int = 8


func _ready():
	anim_player.speed_scale = Push_Speed
	label.text = str(Push_Speed)
	rotation = Vector3(0,0,0)
	
func bounce() -> void:
	anim_player.play("Push")


func _on_ball_detection_body_entered(body):
	bounce()

var mouse_over: bool = false

func _on_push_pad_moving_mouse_entered():
	mouse_over = true
	push_pad.sync_to_physics = true
#	mesh.material_override.
#	mesh.mesh.surface_get_material(some_surface_index)

func _on_push_pad_moving_mouse_exited():
	mouse_over = false

func _input(event):
	if mouse_over:
		if event.is_action_pressed("scroll_up"):
			push_pad.sync_to_physics = true
			Push_Speed += 1
			anim_player.speed_scale = Push_Speed
			label.text = str(Push_Speed)
		elif event.is_action_pressed("scroll_down"):
			Push_Speed -= 1
			anim_player.speed_scale = Push_Speed
			label.text = str(Push_Speed)
