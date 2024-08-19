extends CardEffect

func on_trigger(target: Pendulum) -> void:
	target.move_velocity *= -1
	print("inverseSucc")
