extends Marker3D

# Speed of movement and deceleration factor
const speed: float = 5.0
const deceleration: float = 7
var current_velocity = Vector3(0, 0, 0)

@onready var camera = $TrackballCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement = Vector3(0, 0, 0)

	# Get the camera's forward and right directions, but constrain to XZ plane
	var camera_forward = -camera.get_global_transform().basis.z
	camera_forward.y = 0
	var camera_right = camera.get_global_transform().basis.x
	camera_right.y = 0

	# Check for WASD or arrow key input
	if Input.is_action_pressed("ui_left"):
		movement -= camera_right
	if Input.is_action_pressed("ui_right"):
		movement += camera_right
	if Input.is_action_pressed("ui_up"):
		movement += camera_forward
	if Input.is_action_pressed("ui_down"):
		movement -= camera_forward

	# Normalize the movement vector to ensure consistent speed in all directions
	movement = movement.normalized() * speed

	# Smoothly decelerate when no input is detected
	if movement.length() == 0:
		current_velocity = current_velocity.lerp(Vector3(0, 0, 0), deceleration * delta)
	else:
		current_velocity = movement

	# Apply the movement
	self.translate(current_velocity * delta)
