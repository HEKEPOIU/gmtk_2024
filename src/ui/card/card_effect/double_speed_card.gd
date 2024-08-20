extends CardEffect
@export var times := 2

func _init():
	name = 'double_speed'

func on_trigger(target: Pendulum) -> void:
	target.angular_velocity *= times
	print("add speed")
