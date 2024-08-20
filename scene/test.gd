extends Control


@onready var canvas: UiMain = get_node("Control")

@export var pen: Pendulum

@export var inverse_speed_card: Resource = preload("res://src/ui/card/card_effect/inverse_speed_card.gd")
@export var add_speed_card: Resource = preload("res://src/ui/card/card_effect/add_speed_card.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	canvas.on_card_click.connect((func() -> void: canvas.show_border(get_pendulum_info_array(), Vector2(1, 1))))
	canvas.game_start.connect(func() -> void:
		print('print list')
		canvas.refresh_card_state([add_speed_card.new()]))
	pass # Replace with function body.

func get_pendulum_info_array() -> Array:
	var arr := Array([], TYPE_OBJECT, "Node", Pendulum)
	arr.append(pen)
	return arr

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
