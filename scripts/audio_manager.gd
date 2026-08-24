extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer

### MUSIC ###
var soundtrack = preload("res://audio/music/KoboldSong.wav")

func _ready():
	event_bus.toggleMute.connect(toggleMute)
	
	play_music(soundtrack)

func _input(event):
	if event.is_action_pressed("mute"):
		toggleMute()

func toggleMute():
	var master_bus = AudioServer.get_bus_index("Master")
	var is_muted = AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(0, !is_muted)
	
func play_music(stream : AudioStream, pitch : float = 1.0):
	if music_player.stream == stream:
		music_player.pitch_scale = pitch
		return
	music_player.stream = stream
	music_player.play()
	
func play_sfx(stream: AudioStream, volume : float = -30.0):
	var instance = AudioStreamPlayer.new()
	
	instance.stream = stream
	instance.bus = "Master"
	instance.volume_db = volume
	
	add_child(instance)
	instance.play()
	
	instance.finished.connect(instance.queue_free)
