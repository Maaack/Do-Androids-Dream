extends KinematicBody2D

# the magnet_factor to apply whent the magnet is on or off
const MAGNET_OFF = 1
const MAGNET_ON = 5

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

export var acceleration = 600
export var max_speed = 125
export var friction = 600

var velocity = Vector2.ZERO
var magnet_factor = 1 # this factor will be multiplied in the sheep logic to decide if it should prioritize to follow the shepherd

func _physics_process(delta):
	magnet_factor = MAGNET_ON if Input.is_action_pressed("interact") else MAGNET_OFF
	move_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_state.travel("Walk")
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move()

func move():
	if velocity.length() > 30:
		$StreamCycler2D.play()
	else:
		$StreamCycler2D.stop()
	velocity = move_and_slide(velocity)
