extends KinematicBody2D

signal parts_assembled
signal part_collected
signal magnet_collected
# the magnet_factor to apply whent the magnet is on or off
const MAGNET_OFF = 1
const MAGNET_ON = 5

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

export var acceleration = 600
export var max_speed = 125
export var friction = 600
export(Texture) var shepherd_and_magnet : Texture
export(Texture) var shepherd_no_magnet : Texture

var velocity = Vector2.ZERO
var move_vector : Vector2 = Vector2.ZERO setget set_move_vector
var magnet_flag : bool = false
var magnet_factor = 1 # this factor will be multiplied in the sheep logic to decide if it should prioritize to follow the shepherd
var parts_collected = 0
var has_magnet : bool = false

func _unhandled_input(event):
	if event.is_action_pressed("interact") and has_magnet:
		if magnet_flag:
			magnet_factor = MAGNET_OFF
			$MagnetSprite.hide()
			$MagnetStreamCycler2D.stop()
		else:
			magnet_factor = MAGNET_ON
			$MagnetSprite.show()
			$MagnetStreamCycler2D.play()
		magnet_flag = !(magnet_flag)

func set_move_vector(value : Vector2):
	move_vector = value.normalized()

func move_state(delta):
	if move_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", move_vector)
		animation_tree.set("parameters/Walk/blend_position", move_vector)
		animation_state.travel("Walk")
		velocity = velocity.move_toward(move_vector * max_speed, acceleration * delta)
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

func collect_magnet() -> bool:
	emit_signal("magnet_collected")
	has_magnet = true
	$Sprite.texture = shepherd_and_magnet
	return true

func _ready():
	$Sprite.texture = shepherd_no_magnet

func get_current_zoom():
	return $Camera2D.zoom
