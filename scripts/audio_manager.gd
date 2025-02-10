extends Node

@onready var type: AudioStreamPlayer = $Type
@onready var correct_letter: AudioStreamPlayer = $CorrectLetter
@onready var wrong_letter: AudioStreamPlayer = $WrongLetter
@onready var word_complete: AudioStreamPlayer = $WordComplete
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var next_level: AudioStreamPlayer = $NextLevel
@onready var game_over: AudioStreamPlayer = $GameOver
@onready var tank_sound: AudioStreamPlayer = $TankSound
@onready var player_die: AudioStreamPlayer = $PlayerDie
@onready var mech_step: AudioStreamPlayer = $MechStep
@onready var click: AudioStreamPlayer = $Click
@onready var ui_hit: AudioStreamPlayer = $UI_hit
@onready var ui_hover: AudioStreamPlayer = $UI_hover
@onready var explosion: AudioStreamPlayer = $Explosion
@onready var streak: AudioStreamPlayer = $Streak
@onready var mega_streak: AudioStreamPlayer = $MegaStreak
@onready var heart_beat: AudioStreamPlayer = $HeartBeat
@onready var space_ship: AudioStreamPlayer = $SpaceShip
@onready var boss: AudioStreamPlayer = $Boss
@onready var cinematic_hit: AudioStreamPlayer = $CinematicHit
@onready var hypertype_voice: AudioStreamPlayer = $HypertypeVoice


func _ready():
	background_music.process_mode = Node.PROCESS_MODE_ALWAYS
