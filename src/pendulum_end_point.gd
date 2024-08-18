extends Area2D

class_name PendulumEndPoint

@export var min_scale: float = 1
@export var max_scale: float = 5

signal on_hit_other(other: Pendulum)


func _ready() -> void:
	area_entered.connect(emit_hit)


func emit_hit(body: Area2D) -> void:
	if body is PendulumEndPoint:
		on_hit_other.emit(body.get_parent() as Pendulum)


func set_scale_base_mass(mass: float, min_mass: float, max_mass: float) -> void:
	var new_scale: float = remap(mass, min_mass, max_mass, min_scale, max_scale)
	scale = Vector2(new_scale, new_scale)
