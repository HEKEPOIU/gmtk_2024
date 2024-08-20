extends CardEffect
@export var times := 10

func _init():
	name = 'add speed'
func on_trigger(target: Pendulum) -> void:
	var dir: float = target.angular_velocity / abs(target.angular_velocity)
	if dir != 1 && dir != -1:
		dir = 1
	target.add_velocity(times * dir)
	print("add speed")
