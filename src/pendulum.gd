extends Node2D

class_name Pendulum
# follow this video:
# https://www.youtube.com/watch?v=J1ClXGZIh00
signal start
var pivot_pos: Vector2
var end_position: Vector2
var angle: float
var move_dir: int = 0
var prev_pos: Vector2
var is_simulating: bool = true
@export var move_velocity: float = 5
@export var is_follow: bool = true

@export var length: float = 500
@export var gravity: float = 24
@export var end_point_move_multiplier: float = 5
var damping: float:
	get:
		return remap(mass, min_mass, max_mass, 0.995, 0.99)
@export var mass: float = 1
@export var min_mass: float = 1
@export var max_mass: float = 1000
@export var is_current: bool = false

var angular_velocity: float = 0.0
var angular_acceleration: float = 0.0
@onready var end_point: PendulumEndPoint = get_node("PendulumEndPoint")
@onready var line: Line2D = get_node("Line2D")


func _ready() -> void:
	end_point.on_hit_other.connect(deal_collide)
	end_point.on_drag.connect(be_drag)
	end_point.on_drag_stop.connect(start_simulate)
	end_point.set_scale_base_mass(mass, min_mass, max_mass)
	set_start_position(rotation)


func _physics_process(delta: float) -> void:
	if not is_simulating:
		return
	var pos_diff := global_position - prev_pos
	prev_pos = global_position
	process_velocity(delta, pos_diff)
	update_position(delta, pos_diff)
	move(delta)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		move_dir -= 1
	if Input.is_key_pressed(KEY_RIGHT):
		move_dir += 1


func move(delta: float) -> void:
	position.x += move_dir * move_velocity * delta
	move_dir = 0


func set_start_position(init_angle: float) -> void:
	pivot_pos = global_position
	end_position = global_position + Vector2.DOWN.rotated(init_angle) * length
	end_point.global_position = end_position
	line.set_point_position(1, Vector2(0, length))
	angle = init_angle
	angular_velocity = 0
	angular_acceleration = 0
	rotation = angle


func update_position(delta: float, pos_dif: Vector2) -> void:
	if is_follow:
		angle += move_dir * delta * abs(pos_dif.x) * delta * end_point_move_multiplier


func process_velocity(delta: float, _pivot_pos_diff: Vector2) -> void:
	angular_acceleration = (-gravity * delta) / length * sin(angle)
	angular_velocity += angular_acceleration
	angular_velocity *= damping
	angle += angular_velocity

	rotation = angle


func add_velocity(velocity: float) -> void:
	angular_velocity += velocity


func set_mass(new_mass: float) -> void:
	mass = new_mass
	end_point.set_scale_base_mass(mass, min_mass, max_mass)


func deal_collide(other: Pendulum) -> void:
	if not is_current:
		is_current = true
		return
	var percent: float = mass / other.mass
	# u = (m_s * v_s + m_o * v_o) / (m_s + m_o)
	# https://zh.wikipedia.org/zh-tw/%E6%93%BA
	var new_velocity := (
		(mass * angular_velocity + other.mass * other.angular_velocity)
		/ (mass + other.mass)
		* percent
	)

	other.set_mass(mass + other.mass)
	other.add_velocity(new_velocity)

	queue_free()


func be_drag() -> void:
	if not is_current:
		return
	# TODO: this will cause line not follow
	var dir_to_mouse := (get_global_mouse_position() - pivot_pos).normalized()
	var mouse_angle := -dir_to_mouse.angle_to(Vector2.DOWN)
	set_start_position(mouse_angle)


func start_simulate() -> void:
	if is_current:
		start.emit()
