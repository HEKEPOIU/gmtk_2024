extends Node

class_name GameManarger

signal on_start
@onready var canvas := get_node("CanvasLayer/Canvas") as UiMain
@onready var camera: CameraManager = get_node("Camera2D")
@onready var pendulum_manager: PendulumManager = get_node("PendulumManager")
@onready var audio_manager: AudioManager = get_node("AudioManager")
var is_start_swing: bool = false

@export var inverse_speed_card: Resource = preload("res://src/ui/card/card_effect/inverse_speed_card.gd")
@export var add_speed_card: Resource = preload("res://src/ui/card/card_effect/add_speed_card.gd")
@export var double_speed_card: Resource = preload("res://src/ui/card/card_effect/double_speed_card.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pendulum_manager.on_change_pendulum.connect(camera.deal_follow)
	pendulum_manager.release_pendulum.connect(start_game)
	pendulum_manager.collide.connect(audio_manager.play_collide)
	pendulum_manager.init_pendulums()

	canvas.on_card_click.connect((func() -> void: canvas.show_border(pendulum_manager.get_all_pendulum(), Vector2(1, 1))))
	canvas.game_start.connect(func() -> void:
		print('print list')
		canvas.refresh_card_state([add_speed_card.new(), inverse_speed_card.new(), double_speed_card.new()]))

func start_game() -> void:
	if is_start_swing:
		return
	is_start_swing = true
	on_start.emit()
