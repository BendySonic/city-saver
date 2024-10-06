extends Node2D

signal spaced
@export var player: Node2D

func _ready() -> void:
	player.is_tutorial = true
	$AnimationPlayer.play("white_off")
	await spaced
	$CanvasLayer3/Control/Label.text = "Use mouse to move. Just click and hold."
	await player.moved
	await spaced
	$CanvasLayer3/Control/Label.text = "Tap 'Q' to DASH"
	await player.dashed
	await spaced
	$CanvasLayer3/Control/Label.text = "Tap '1' for LASER ATTACK"
	await player.lasered
	await spaced
	$CanvasLayer3/Control/Label.text = "Tap '2' for GROUND PUNCH"
	await player.grounded
	await spaced
	$CanvasLayer3/Control/Label.text = "Tap '3' for CONSECUTIVE LASERS"
	await player.greened
	await spaced
	$CanvasLayer3/Control/Label.text = "You also can use ultimate attack.\nCheck it in the fight (Tap '4').\n Good Luck!"
	await spaced
	$AnimationPlayer.play("white_on")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://src/city.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("space"):
		spaced.emit()
