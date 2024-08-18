extends Button

class_name Card


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_up() -> void:
	Lib.disable(self)
	pass  # Replace with function body.
