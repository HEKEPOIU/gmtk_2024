extends Area2D

class_name PendulumEndPoint

@export var min_scale: float = 1
@export var max_scale: float = 5
@export var size_tween_length: float = 0.5

signal on_hit_other(other: Pendulum)
signal on_drag
signal on_drag_stop
var is_mouse_inside: bool
var is_click: bool = false
var collider_other: Pendulum

@onready var sprite: Sprite2D = get_node("Sprite2D")


func _ready() -> void:
	area_entered.connect(enter_body)
	area_exited.connect(exit_area)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press") and is_mouse_inside:
		is_click = true
	elif Input.is_action_just_released("press"):
		is_click = false
	if is_click:
		on_drag.emit()
	elif Input.is_action_just_released("press") and is_mouse_inside:
		on_drag_stop.emit()

	if collider_other:
		on_hit_other.emit(collider_other)


func set_sprite(image: Texture2D) -> void:
	sprite.texture = image


func enter_body(body: Area2D) -> void:
	if body is PendulumEndPoint:
		collider_other = body.get_parent() as Pendulum

func exit_area(body: Area2D) -> void:
	if body is PendulumEndPoint:
		collider_other = null


func set_scale_base_mass(mass: float, min_mass: float, max_mass: float) -> void:
	var new_scale: float = remap(mass, min_mass, max_mass, min_scale, max_scale)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(new_scale, new_scale), size_tween_length)


func _mouse_enter() -> void:
	is_mouse_inside = true


func _mouse_exit() -> void:
	is_mouse_inside = false
	if is_click:
		on_drag_stop.emit()
