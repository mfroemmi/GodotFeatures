extends Node3D

@export var dayNightAnimationPlayer: AnimationPlayer

func _ready() -> void:
	GameLifecycleSignals.pause_animation.connect(self._on_pause_animation)
	
	var animation = dayNightAnimationPlayer.get_animation("day_night_cycle")
	animation.loop = true
	
	var anim_track_day_index = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(anim_track_day_index, ".")
	animation.track_insert_key(anim_track_day_index, 0.1, {
		"method": "emit_day_time_signal",
		"args": [],
	}, 0)

	var anim_track_night_index = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(anim_track_night_index, ".")
	animation.track_insert_key(anim_track_night_index, 7.5, {
		"method": "emit_night_time_signal",
		"args": [],
	}, 0)

func emit_day_time_signal():
	GameLifecycleSignals.day_time.emit()

func emit_night_time_signal():
	GameLifecycleSignals.night_time.emit()

func _on_pause_animation(duration):
	dayNightAnimationPlayer.playback_active = false
	await get_tree().create_timer(duration).timeout
	dayNightAnimationPlayer.playback_active = true
