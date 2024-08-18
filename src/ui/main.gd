extends Control

class_name UiMain

var card := preload("res://scene/card.tscn")

@onready var startUi := get_node("StartUi")
@onready var cardContainer := get_node("PanelContainer/HBoxContainer")

signal game_start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cardContainer == null:
		create_new_card_container()
	print(card)
	pass  # Replace with function body.


func create_new_card_container() -> void:
	if cardContainer != null:
		cardContainer.queue_free()
	cardContainer = HBoxContainer.new()
	get_node("PanelContainer").add_child(cardContainer)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _refresh_card_state(list: PackedStringArray) -> void:
	create_new_card_container()  # todo: here can just update text
	for i in list:
		var ins: Card = card.instantiate() as Card
		ins.text = i
		cardContainer.add_child(ins)
	pass  # Replace with function body.


func _on_start_button_up() -> void:
	create_new_card_container()
	_refresh_card_state(["1", "2", "3", "4", "5"])

	Lib.disable(startUi)

	game_start.emit()
	pass  # Replace with function body.
