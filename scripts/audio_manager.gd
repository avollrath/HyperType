extends Node

@onready var type: AudioStreamPlayer = $Type
@onready var correct_letter: AudioStreamPlayer = $CorrectLetter
@onready var wrong_letter: AudioStreamPlayer = $WrongLetter
@onready var word_complete: AudioStreamPlayer = $WordComplete
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var next_level: AudioStreamPlayer = $NextLevel
@onready var game_over: AudioStreamPlayer = $GameOver
