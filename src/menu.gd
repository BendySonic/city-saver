extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("white_off")

func _on_label_pressed() -> void:
	$AnimationPlayer.play("white_on")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://src/city.tscn")


func _on_label_2_pressed() -> void:
	$AnimationPlayer.play("white_on")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://src/tutorial.tscn")
