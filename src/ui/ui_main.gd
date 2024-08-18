extends Control

class_name UiMain

var card := preload("res://scene/card.tscn")
# var borderPrefab := preload("res://src/ui/card/border.tscn")
@export var border: NinePatchRect

@onready var startUi := get_node("StartUi")
@onready var cardContainer := get_node("PanelContainer/HBoxContainer")
@export var test_pendulum: Pendulum

signal game_start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	print(card)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _refresh_card_state(list: PackedStringArray) -> void:
	for i in list:
		var ins: Card = card.instantiate() as Card
		ins.text = i
		ins.on_card_click.connect(_on_card_click)
		cardContainer.add_child(ins)
		
	pass # Replace with function body.

func _on_card_click() -> void:
	print("card click")
	var arr := _get_pendulum_info_array()
	for p: Pendulum in arr:
		var position: Vector2 = p.position
		var length: float = p.length # todo:p.get_length()
		var width: float = (p.get_node("PendulumEndPoint/Sprite2D") as Sprite2D).texture.get_size().x # todo: p.get_width()
		# var border := borderPrefab.instantiate()  # todo: use prefab , idk why no appear when use prefab 
		set_border(position - Vector2(width / 2, 0), Vector2(width, length))
	pass

func set_border(target_positon: Vector2, target_size: Vector2):
	border.position = target_positon
	border.size = target_size

func _get_pendulum_info_array() -> Array:
	var arr := Array([], TYPE_OBJECT, "Node", Pendulum)
	arr.append(test_pendulum)
	return arr

func _on_start_button_up() -> void:
	_refresh_card_state(["1", "2", "3", "4", "5"])

	UiHelper.disable(startUi)

	game_start.emit()
	pass # Replace with function body.
