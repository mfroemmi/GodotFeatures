extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameLifecycleSignals.day_time.connect(self._on_day_time)
	GameLifecycleSignals.night_time.connect(self._on_night_time)

func _on_day_time():
	print("day_time")
	GameLifecycleSignals.pause_animation.emit(0.5)

func _on_night_time():
	print("night_time")
