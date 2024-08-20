extends CardEffect
@export var times := 10

func on_trigger(target: Pendulum) -> void:
	var dir: float = target.angular_velocity / abs(target.angular_velocity)
	if dir != 1 && dir != -1:
		dir = 10
	target.angular_velocity += times * dir
	print("add speed")
