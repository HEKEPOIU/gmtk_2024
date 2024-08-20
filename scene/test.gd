extends Control


@onready var canvas :UiMain= get_node("Control")
@export var pen : Pendulum
# Called when the node enters the scene tree for the first time.
func _ready():
	canvas.on_card_click.connect((func ()->void : canvas.show_border(get_pendulum_info_array(),Vector2(1,1))))
	pass # Replace with function body.

func get_pendulum_info_array()->Array:
	var arr:= Array([], TYPE_OBJECT, "Node", Pendulum)
	arr.append(pen)
	return arr

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
