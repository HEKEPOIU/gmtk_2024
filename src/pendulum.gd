extends Node2D

# follow this video:
# https://www.youtube.com/watch?v=J1ClXGZIh00
var pivot_pos: Vector2
var end_position: Vector2
var angle: float

@export var length: float = 500
@export var gravity: float = 24
var damping: float:
	get:
		return remap(mass, min_mass, max_mass, 0.995, 0.95)
@export var mass: float = 1
@export var min_mass: float = 1
@export var max_mass: float = 1000

var angular_velocity: float = 0.0
var angular_acceleration: float = 0.0
@onready var end_point: Node2D = get_node("Area2D")
@onready var line: Line2D = get_node("Line2D")


func set_start_position(init_angle: float, arm_length: float) -> void:
	pivot_pos = global_position
	end_position = global_position + Vector2.DOWN.rotated(init_angle) * arm_length
	end_point.global_position = end_position
	line.set_point_position(1, Vector2(0, arm_length))
	angle = init_angle


func process_velocity(delta: float) -> void:
	angular_acceleration = (-gravity * delta) / length * sin(angle)
	angular_velocity += angular_acceleration
	angular_velocity *= damping
	angle += angular_velocity

	rotation = angle


func _ready() -> void:
	set_start_position(rotation, length)


func _physics_process(delta: float) -> void:
	process_velocity(delta)
