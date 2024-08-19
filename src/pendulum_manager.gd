extends Node

class_name PendulumManager

signal on_change_pendulum(new_current: Pendulum)
@export var pendulum_scene: Array[PackedScene]
@export var pendulum_margin: float = 320
@export var pendulum_pivot_height: int = 360
@export var start_offset: float = 0
@export var move_time: float = 0.5

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
	current_pendulum.global_position = Vector2(window_size.x / 2., pendulum_pivot_height)
	for i in range(pre_generate_size):
		left_pendulums.push_back(spawn_pendulum_on_container(i, -1))
		right_pendulums.push_back(spawn_pendulum_on_container(i, 1))
	on_change_pendulum.emit(current_pendulum)
	call_deferred("emit_signal", "on_change_pendulum", current_pendulum)


func spawn_pendulum_on_container(index: int, dir: int) -> Pendulum:
	var new_pendulum: Pendulum = generate_random_pendulum()
	new_pendulum.be_current.connect(current_change)
	# if not this it godot debugger will runtime error,
	# but it won't stop play_mode on my machine
	call_deferred("add_child", new_pendulum)
	if dir != 0:
		new_pendulum.global_position = (
			center_pivot_point + Vector2(dir * (index + 1) * pendulum_margin, 0)
		)
	return new_pendulum


func generate_random_pendulum() -> Pendulum:
	return pendulum_scene.pick_random().instantiate()


func current_change(pendulum: Pendulum) -> void:
	# 1. Change the margin
	# 2. Find new pendulum in which array
	# 3. spawn new pendulum fill on back
	# 4. move other side array move to current side.
	current_pendulum = pendulum

	if current_pendulum in left_pendulums:
		spawn_on_array(left_pendulums)
		move_pendulums(right_pendulums)
	else:
		spawn_on_array(right_pendulums)
		move_pendulums(left_pendulums)
	on_change_pendulum.emit(current_pendulum)


func spawn_on_array(target_array: Array[Pendulum]) -> void:
	#TODO: Change to delete smaller index.
	var current_index := target_array.find(current_pendulum)
	for i in current_index + 1:
		target_array.pop_front()
	var dir: int = 1 if target_array == right_pendulums else -1
	for i in current_index + 1:
		var new_pendulum: Pendulum = spawn_pendulum_on_container(target_array.size(), dir)
		target_array.push_back(new_pendulum)


func move_pendulums(target_array: Array[Pendulum]) -> void:
	var dir: int = 1 if target_array == right_pendulums else -1
	for i in target_array.size():
		var tween: Tween = create_tween()
		tween.tween_property(
			target_array[i],
			"global_position",
			center_pivot_point + Vector2(dir * (i + 1) * pendulum_margin, 0),
			move_time
		)
		tween.tween_callback(func() -> void: target_array[i].is_moving = false)
		target_array[i].is_moving = true
