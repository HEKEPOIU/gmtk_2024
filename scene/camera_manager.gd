extends Camera2D

@onready var camera2d := get_node("Camera2D") as Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _tween_to_fit_screen(scale: Vector2, position: Vector2) -> void:

	var tween := create_tween()
	tween.tween_property(camera2d, "zoom", scale, 1)
	var tween1 := create_tween()
	tween1.tween_property(camera2d, "position", position, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
