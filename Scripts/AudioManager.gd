extends AudioStreamPlayer

@export var music_list = preload("res://PreloadedClasses/MusicList.tres").sound_list
@export var sfx_list = preload("res://PreloadedClasses/SFXList.tres").sound_list

func play_music(music_name : String):
	var music_sound : Sound = get_sound_from_name(music_name)
	if music_sound == null:
		return
	
	if music_sound.sound_file == stream:
		return
	
	stream = music_sound.sound_file
	bus = music_sound.bus
	volume_db = music_sound.volume
	pitch_scale = music_sound.pitch
	
	play(0.0)

func play_sfx(sfx_name : String):
	var sfx_sound : Sound = get_sound_from_name(sfx_name)
	if sfx_sound == null:
		return
	
	var new_asp = AudioStreamPlayer.new()
	
	new_asp.stream = sfx_sound.sound_file
	new_asp.bus = sfx_sound.bus
	new_asp.volume_db = sfx_sound.volume
	new_asp.pitch_scale = sfx_sound.pitch
	
	add_child(new_asp)
	
	new_asp.play(0)
	
	await new_asp.finished
	
	new_asp.queue_free()

func get_sound_from_name(sound_name : String) -> Sound:
	for sound in music_list:
		if sound.name == sound_name:
			return sound
	for sound in sfx_list:
		if sound.name == sound_name:
			return sound
	print("Sound Not Found")
	return null
