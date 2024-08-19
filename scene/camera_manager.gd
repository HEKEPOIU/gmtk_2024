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
	if new_follow.end_point:
		var camera_size_y = self.get_viewport().size.y
		var original_size: float = (camera_size_y)
		var end_point := new_follow.end_point
		var ball_size: float = get_end_point_size(end_point)
		var target_size := (ball_size / 0.2)
		zoom_size = 2 * (target_size / original_size) * Vector2.ONE
		zoom_size = zoom_size
	else:
		zoom_size = Vector2.ONE

func get_end_point_size(end_point) -> float:
	var ball_size: float = end_point.sprite.get_rect().size.y * end_point.scale.y * end_point.sprite.scale.y
	return ball_size
