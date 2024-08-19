extends Camera2D

class_name CameraManager

@export var move_duration: float = 0.2
var follow_pos: Vector2
var zoom_size: Vector2


func tween_to_fit_screen(target_position: Vector2, target_scale: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "zoom", Vector2.ONE / target_scale, move_duration)
	var tween1 := create_tween()
	tween1.tween_property(self, "position", target_position, move_duration)


func _process(_delta: float) -> void:
	tween_to_fit_screen(follow_pos, zoom_size)


func deal_follow(new_follow: Pendulum) -> void:
	follow_pos = new_follow.global_position + Vector2(0, new_follow.length)
	print(new_follow.length)
	zoom_size = new_follow.length / 800 * Vector2.ONE
