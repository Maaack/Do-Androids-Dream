extends KinematicBody2D
class_name Shepherd

signal parts_assembled
signal part_collected
signal magnet_collected
signal battery_collected
signal repeller_collected

enum Equipped{
	NOTHING,
	REPELLER,
	ATTRACTOR,
	BATTERY,
}

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

export var acceleration = 600
export var max_speed = 125
export var friction = 600
export(Texture) var shepherd_texture : Texture
export(Texture) var shepherd_with_attractor : Texture
export(Texture) var shepherd_with_repeller : Texture
export(Texture) var shepherd_with_battery : Texture

var velocity = Vector2.ZERO
var move_vector : Vector2 = Vector2.ZERO setget set_move_vector
var parts_collected : int = 0
var equipped_states : Array = [Equipped.NOTHING]
var equipped_state_iter : int = 0
var equipment_active : bool = false
var chargeable_sheep : Dictionary = {}

func get_equipped_state():
	return equipped_states[equipped_state_iter]

func _update_shepherd_texture():
	var equipped_state : int = get_equipped_state()
	match(equipped_state):
		Equipped.NOTHING:
			$Sprite.texture = shepherd_texture
		Equipped.ATTRACTOR:
			$Sprite.texture = shepherd_with_attractor
		Equipped.REPELLER:
			$Sprite.texture = shepherd_with_repeller
		Equipped.BATTERY:
			$Sprite.texture = shepherd_with_battery

func is_nothing_equipped():
	return get_equipped_state() == Equipped.NOTHING

func is_magnet_equipped():
	return get_equipped_state() == Equipped.ATTRACTOR

func is_magnet_active():
	return is_magnet_equipped() and equipment_active

func is_repeller_equipped():
	return get_equipped_state() == Equipped.REPELLER

func is_repeller_active():
	return is_repeller_equipped() and equipment_active

func is_battery_equipped():
	return get_equipped_state() == Equipped.BATTERY

func _update_item_animation():
	var equipped_state : int = get_equipped_state()
	match(equipped_state):
		Equipped.NOTHING:
			$ItemAnimationPlayer.play("None")
		Equipped.ATTRACTOR:
			if equipment_active:
				$ItemAnimationPlayer.play("MagnetOn")
			else:
				$ItemAnimationPlayer.play("MagnetOff")
		Equipped.REPELLER:
			if equipment_active:
				$ItemAnimationPlayer.play("RepellerOn")
			else:
				$ItemAnimationPlayer.play("RepellerOff")
		Equipped.BATTERY:
			if chargeable_sheep.size() > 0:
				$ItemAnimationPlayer.play("BatteryOn")
			else:
				$ItemAnimationPlayer.play("BatteryOff")

func _update_item_sfx():
	if equipment_active:
		$MagnetStreamCycler2D.play()
	else:
		$MagnetStreamCycler2D.stop()

func _update_equipped_active():
	_update_item_animation()
	_update_item_sfx()

func add_chargeable_sheep(name : String, instance : Node2D):
	chargeable_sheep[name] = instance
	_update_item_animation()

func remove_chargeable_sheep(name : String):
	if name in chargeable_sheep:
		chargeable_sheep.erase(name)
		_update_item_animation()

func toggle_equipped():
	if is_nothing_equipped():
		return
	if is_battery_equipped() and chargeable_sheep.size() > 0:
		for sheep_name in chargeable_sheep:
			var sheep_instance = chargeable_sheep[sheep_name]
			sheep_instance.charge()
		chargeable_sheep.clear()
		remove_battery_equip_state()
		return
	equipment_active = !(equipment_active)
	_update_equipped_active()

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

func remove_nothing_equip_state():
	if Equipped.NOTHING in equipped_states:
		equipped_states.erase(Equipped.NOTHING)
		swap()

func remove_battery_equip_state():
	if Equipped.BATTERY in equipped_states:
		equipped_states.erase(Equipped.BATTERY)
		swap()

func collect_item(item_id : int):
	#remove_nothing_equip_state()
	if item_id in equipped_states:
		return false
	equipped_states.append(item_id)
	if is_nothing_equipped():
		equipped_state_iter = equipped_states.size() - 1
		_update_equipped_active()
		_update_shepherd_texture()
	return true
	

func collect_magnet() -> bool:
	emit_signal("magnet_collected")
	return collect_item(Equipped.ATTRACTOR)

func collect_repeller() -> bool:
	emit_signal("repeller_collected")
	return collect_item(Equipped.REPELLER)

func collect_battery() -> bool:
	emit_signal("battery_collected")
	return collect_item(Equipped.BATTERY)

func swap():
	var new_equipped_state_iter = equipped_state_iter + 1
	if new_equipped_state_iter >= equipped_states.size():
		new_equipped_state_iter = 0
	if new_equipped_state_iter == equipped_state_iter:
		return
	equipped_state_iter = new_equipped_state_iter
	equipment_active = false
	_update_equipped_active()
	_update_shepherd_texture()

func _ready():
	_update_shepherd_texture()

func get_current_zoom():
	return $Camera2D.zoom

