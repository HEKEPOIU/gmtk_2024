extends Node

class_name AudioManager

@onready var collide_sound: AudioStreamPlayer2D = get_node("ColideBall")
@onready var card_effecr: AudioStreamPlayer2D = get_node("CardEffect")


func play_collide() -> void:
	collide_sound.play()

func play_card_effect_sound() -> void:
	card_effecr.play()

