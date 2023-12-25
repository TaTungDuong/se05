extends Node2D
var rng = RandomNumberGenerator.new()
var next_scene = null
var ratio

func _ready():
	rng.randomize()
	ratio = rng.randf_range(1.5, 2.5) + 3
	$HustLoop.speed_scale = rng.randf_range(1.25, 2.5) * ratio
	$Progress.speed_scale = rng.randf_range(0.125, 0.25) * ratio
	$Loading.speed_scale  = rng.randf_range(0.125, 0.25) * ratio

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and next_scene == null:
		get_tree().reload_current_scene()

func change_scene():
	get_tree().change_scene_to_file(next_scene)
	queue_free()
