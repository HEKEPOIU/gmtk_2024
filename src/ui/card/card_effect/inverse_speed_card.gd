extends CardEffect

func _init():
	name = 'inverse speed'
func on_trigger(target: Pendulum) -> void:
	target.angular_velocity *= -1
	print("inverseSucc")
