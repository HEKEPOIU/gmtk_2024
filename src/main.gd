extends Node

class_name GameManarger

@onready var canvas := get_node("CanvasLayer/Canvas") as UiMain
@onready var camera: CameraManager = get_node("Camera2D")
@onready var pendulum_manager: PendulumManager = get_node("PendulumManager")
var is_start_swing: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pendulum_manager.on_change_pendulum.connect(camera.deal_follow)
	pendulum_manager.release_pendulum.connect(start_game)
	pendulum_manager.init_pendulums()

func start_game() -> void:
	is_start_swing = true
