extends Button

class_name Card


@export var card_effect: CardEffect = preload("res://src/ui/card/card_effect/inverse_speed_card.gd").new()

signal on_card_click

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_up() -> void:
	on_card_click.emit(self)
	# UiHelper.disable(self)

	pass # Replace with function body.
