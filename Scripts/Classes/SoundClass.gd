class_name Sound
extends Resource

@export_placeholder("SoundName") var name : String 
@export var sound_file : AudioStreamMP3
@export_range(-80,24,0.1) var volume : float = 0.0
@export_range(0.1,5,0.1) var pitch : float = 1.0
@export_enum("Master", "Music", "SFX") var bus : String = "SFX"
