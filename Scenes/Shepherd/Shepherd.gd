extends KinematicBody2D

signal parts_assembled
signal part_collected
# the magnet_factor to apply whent the magnet is on or off
const MAGNET_OFF = 1
const MAGNET_ON = 5

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

export var acceleration = 600
export var max_speed = 125
export var friction = 600
export(Color) var magnetized_color : Color = Color.white

var velocity = Vector2.ZERO
var magnet_factor = 1 # this factor will be multiplied in the sheep logic to decide if it should prioritize to follow the shepherd
var parts_collected = 0

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		magnet_factor = MAGNET_ON
		$Sprite.modulate = magnetized_color
		$MagnetStreamCycler2D.play()
	elif event.is_action_released("interact"):
		magnet_factor = MAGNET_OFF
		$Sprite.modulate = Color.white
		$MagnetStreamCycler2D.stop()

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

func _physics_process(delta):
	move_state(delta)

func collect_part() -> bool:
	parts_collected += 1
	emit_signal("part_collected")
	if parts_collected >= 2:
		parts_collected -= 2
		emit_signal("parts_assembled")
		velocity = Vector2.ZERO
	return true

func muse(musing_text):
	$"%MusingLabel".text = musing_text
	$CameraAnimationPlayer.play("Musing")
