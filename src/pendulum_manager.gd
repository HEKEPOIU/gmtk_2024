extends Node

class_name PendulumManager

signal on_change_pendulum(new_current: Pendulum)
signal release_pendulum
signal collide
@export var pendulum_scene: Array[PackedScene]
@export var pendulum_margin: float = 320
@export var pendulum_pivot_height: int = 360
@export var start_offset: float = 400
@export var move_time: float = 0.5
@export var margin_multiply: float = 4
@export var random_range: float = 10

@export var min_margin: float = 320
@export var max_margin: float = 1000

## This is one side pre generate size,
## so that total pendulum on scene is 2 * pre_generate_size + 1
@export var pre_generate_size: int = 2

var current_pendulum: Pendulum
var left_pendulums: Array[Pendulum]
var right_pendulums: Array[Pendulum]

var window_size: Vector2i
var center_pivot_point: Vector2:
	get:
		return current_pendulum.global_position

# order:
#   L	C   R
# 2 1 0   0 1 2


func init_pendulums() -> void:
	window_size = get_window().size
	current_pendulum = spawn_pendulum_on_container(0, 0)
	current_pendulum.is_current = true
	current_pendulum.can_contorl = true
	current_pendulum.global_position = Vector2(window_size.x / 2.,pendulum_pivot_height)
	current_pendulum.on_drag.connect(move_side)
	for i in range(pre_generate_size):
		left_pendulums.push_back(spawn_pendulum_on_container(i, -1))
		right_pendulums.push_back(spawn_pendulum_on_container(i, 1))
	on_change_pendulum.emit(current_pendulum)
	call_deferred("emit_signal", "on_change_pendulum", current_pendulum)
	call_deferred("change_margin")


func spawn_pendulum_on_container(index: int, dir: int) -> Pendulum:
	var new_pendulum: Pendulum = generate_random_pendulum()
	new_pendulum.be_current.connect(current_change)
	new_pendulum.be_eat.connect(remove_pendulum)
	# if not this it godot debugger will runtime error,
	# but it won't stop play_mode on my machine
	call_deferred("add_child", new_pendulum)
	if dir != 0:
		new_pendulum.global_position = (
			center_pivot_point + Vector2(dir * (index + 1) * pendulum_margin, 0)
		)
		new_pendulum.mass = current_pendulum.mass / 2 + (randf() * random_range)
	return new_pendulum

func get_all_pendulum() -> Array[Pendulum]:
	var to_list := [current_pendulum] as Array[Pendulum]
	var total: Array[Pendulum] = left_pendulums + right_pendulums + to_list
	return total

func generate_random_pendulum() -> Pendulum:
	return pendulum_scene.pick_random().instantiate()


func current_change(pendulum: Pendulum) -> void:
	# 1. Change the margin
	# 2. Find new pendulum in which array
	# 3. spawn new pendulum fill on back
	# 4. move other side array move to current side.
	release_pendulum.emit()
	current_pendulum = pendulum
	if is_instance_valid(current_pendulum):
		current_pendulum.can_contorl = false
	change_margin()

	if current_pendulum in left_pendulums:
		spawn_on_array(left_pendulums)
	else:
		spawn_on_array(right_pendulums)
	on_change_pendulum.emit(current_pendulum)
	call_deferred("move_pendulums")

func recycle(pendulum: Pendulum) -> void:
	var index_l: int = left_pendulums.find(pendulum)
	var index_r: int = right_pendulums.find(pendulum)
	if index_l:
		left_pendulums.remove_at(index_l)
		var new_pendulum: Pendulum = spawn_pendulum_on_container(left_pendulums.size(), -1)
		left_pendulums.push_back(new_pendulum)
	elif index_r:
		right_pendulums.remove_at(index_r)
		var new_pendulum: Pendulum = spawn_pendulum_on_container(right_pendulums.size(), 1)
		right_pendulums.push_back(new_pendulum)


func change_margin() -> void:
	var size: Vector2 = current_pendulum.end_point.get_size()
	pendulum_margin = size.x * margin_multiply
	print(pendulum_margin)


func spawn_on_array(target_array: Array[Pendulum]) -> void:
	var current_index := target_array.find(current_pendulum)
	for i in current_index + 1:
		var pop: Pendulum = target_array.pop_front()
		if pop != current_pendulum:
			pop.queue_free()

	delete_small_in_array(left_pendulums)
	delete_small_in_array(right_pendulums)
	for i in (pre_generate_size - left_pendulums.size()):
		var new_pendulum: Pendulum = spawn_pendulum_on_container(left_pendulums.size(), -1)
		left_pendulums.push_back(new_pendulum)

	for i in (pre_generate_size - right_pendulums.size()):
		var new_pendulum: Pendulum = spawn_pendulum_on_container(right_pendulums.size(), 1)
		right_pendulums.push_back(new_pendulum)


func move_pendulums() -> void:
	start_offset_base_dir(0)

func delete_small_in_array(target_array: Array[Pendulum]) -> Array[Pendulum]:
	var del_pendulum: Array[Pendulum]
	for i in range(target_array.size()):
		if target_array[i].mass < current_pendulum.mass / 3:
			del_pendulum.push_back(target_array[i])

	for del in del_pendulum:
		target_array.erase(del)
		del.queue_free()

	return del_pendulum


func move_side(pos: Vector2) -> void:
	var dir: int = 1 if pos.x - current_pendulum.position.x > 0 else -1
	start_offset_base_dir(dir)

func start_offset_base_dir(dir: int) -> void:
	for i in right_pendulums.size():
		var target_pos: Vector2 = Vector2((i + 1) * pendulum_margin + start_offset, 0)
		var oringin_pos: Vector2 = Vector2((i + 1) * pendulum_margin, 0)
		var tween_r: Tween = create_tween()
		tween_r.tween_property(
			right_pendulums[i],
			"global_position",
			center_pivot_point + (target_pos if dir > 0 else oringin_pos), # oringin_pos
			move_time
		)
		tween_r.tween_callback(func() -> void:
			if is_instance_valid(right_pendulums[i]):
				right_pendulums[i].is_moving = false
			)
		if is_instance_valid(right_pendulums[i]):
			right_pendulums[i].is_moving = true


	for i in left_pendulums.size():
		var target_pos: Vector2 = Vector2((i + 1) * pendulum_margin + start_offset, 0)
		var oringin_pos: Vector2 = Vector2((i + 1) * pendulum_margin, 0)
		var tween_l: Tween = create_tween()
		tween_l.tween_property(
			left_pendulums[i],
			"global_position",
			center_pivot_point + -(target_pos if dir < 0 else oringin_pos), # target_pos
			move_time
		)
		tween_l.tween_callback(func() -> void:
			if is_instance_valid(left_pendulums[i]):
				left_pendulums[i].is_moving = false
			)
		if is_instance_valid(left_pendulums[i]):
			left_pendulums[i].is_moving = true

func remove_pendulum(pendulum: Pendulum) -> void:
	collide.emit()
	left_pendulums.erase(pendulum)
	right_pendulums.erase(pendulum)
