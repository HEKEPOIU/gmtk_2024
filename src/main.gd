extends Node

class_name test

@onready var canvas := get_node("CanvasLayer/Canvas") as UiMain


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas.game_start.connect(onStart)
	pass # Replace with function body.



func onStart() -> void:
	print("onStart")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	pass
