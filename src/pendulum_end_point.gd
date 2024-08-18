extends Area2D

class_name PendulumEndPoint

@export var min_scale: float = 1
@export var max_scale: float = 5

signal on_hit_other(other: Pendulum)
signal on_drag
var is_mouse_inside: bool
var is_click: bool = false


func _ready() -> void:
	area_entered.connect(emit_hit)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press"):
		is_click = true
	elif Input.is_action_just_released("press"):
		is_click = false
	if is_click and is_mouse_inside:
		on_drag.emit()


func emit_hit(body: Area2D) -> void:
	if body is PendulumEndPoint:
		on_hit_other.emit(body.get_parent() as Pendulum)


func set_scale_base_mass(mass: float, min_mass: float, max_mass: float) -> void:
	var new_scale: float = remap(mass, min_mass, max_mass, min_scale, max_scale)
	scale = Vector2(new_scale, new_scale)


func _mouse_enter() -> void:
	is_mouse_inside = true


func _mouse_exit() -> void:
	is_mouse_inside = false
