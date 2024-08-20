extends Control

class_name UiMain

var card := preload("res://scene/card.tscn")
# var card_resource := preload("res://src/ui/card/inverse_speed_card.gd")
@export var borderPrefab := preload("res://src/ui/card/border.tscn")
# var border: ChooseBox

@onready var startUi := get_node("StartUi")
@onready var cardContainer := get_node("PanelContainer/HBoxContainer")
@export var test_pendulum: Pendulum
@export var next_card_effect: CardEffect


signal game_start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	print(card)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func refresh_card_state(list) -> void:
	print(list)
	for i: CardEffect in list:
		var ins: Card = card.instantiate() as Card
		print(i.name)
		ins.text = i.name
		ins.card_effect = i
		ins.on_card_click.connect(_on_card_click)
		cardContainer.add_child(ins)

	pass # Replace with function body.

signal on_card_click

func _on_card_click(res: CardEffect) -> void:
	next_card_effect = res
	on_card_click.emit()
	pass
func show_border(arr: Array[Pendulum], border_size: Vector2) -> void:
	for p: Pendulum in arr:
		var length: float = p.length
		var sp := (p.get_node("PendulumEndPoint/Sprite2D") as Sprite2D)
		var width: float = sp.texture.get_size().x * sp.scale.x
		var new_border := borderPrefab.instantiate()
		self.add_child(new_border)
		new_border.on_choose.connect(func() -> void:
			next_card_effect.on_trigger(p)
			UiHelper.disable(new_border)
			)
		set_border(new_border, p.position - Vector2(width / 2, 0), Vector2(width, length)) # todo: use right width
	pass

func set_border(border: ChooseBox, target_positon: Vector2, target_size: Vector2):
	border.global_position = target_positon
	border.size = target_size

func _get_pendulum_info_array() -> Array:
	var arr := Array([], TYPE_OBJECT, "Node", Pendulum)
	arr.append(test_pendulum)
	return arr

func on_start_button_up() -> void:
	# refresh_card_state(["1", "2", "3", "4", "5"])

	UiHelper.disable(startUi)

	print('game start')
	game_start.emit()
	pass # Replace with function body.
