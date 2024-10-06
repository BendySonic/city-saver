extends Node2D

const SHOW_COLOR = Color(1, 1, 1, 1)
const HIDE_COLOR = Color(1, 1, 1, 0.5)

@export var middleground: Node2D
@export var foreground: Node2D
@export var background: Node2D

@export var enemy: Node2D
@export var player: Node2D

@export var health := 100
var destruction_cooldown := 3


func _ready() -> void:
	enemy.health_changed.connect(_on_enemy_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	$AnimationPlayer2.play("white_off")

func _on_middleground_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(middleground, "modulate", HIDE_COLOR, 0.3)

func _on_middleground_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(middleground, "modulate", SHOW_COLOR, 0.3)

func _on_foreground_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(foreground, "modulate", HIDE_COLOR, 0.3)

func _on_foreground_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(foreground, "modulate", SHOW_COLOR, 0.3)

func _on_enemy_health_changed(health: float):
	$CanvasLayer/Control/MarginContainer/HBoxContainer/EnemyHealth.text = str(round(clamp(health, 0, 500)))
	if health <= 0:
		$AnimationPlayer.play("ko")
		await get_tree().create_timer(4).timeout
		$AnimationPlayer2.play("white_off")
		await $AnimationPlayer2.animation_finished
		get_tree().change_scene_to_file("res://src/menu.tscn")

func _on_player_health_changed(health: float):
	$CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer2/PlayerHealth.text = str(round(clamp(health, 0, 500)))
	if health <= 0:
		$AnimationPlayer.play("game_over")
		await get_tree().create_timer(4).timeout
		$AnimationPlayer2.play("white_off")
		await $AnimationPlayer2.animation_finished
		get_tree().change_scene_to_file("res://src/menu.tscn")

func destroy():
	health -= 3
	destruction_cooldown -= 1
	if destruction_cooldown == 0:
		destruction_cooldown = 3
		destroy_random_building()

func destroy_random_building():
	var search_building = true
	var building
	while search_building:
		var random = randi_range(1, 3)
		match random:
			1:
				if background.get_child_count() == 0:
					continue
				building = background.get_children()[randi_range(0, background.get_children().size() - 1)]
			2:
				if middleground.get_child_count() == 0:
					continue
				building = middleground.get_children()[randi_range(0, middleground.get_children().size() - 1)]
			3:
				if foreground.get_child_count() == 0:
					continue
				building = foreground.get_children()[randi_range(0, foreground.get_children().size() - 1)]
		search_building = false
	var tween = get_tree().create_tween()
	tween.tween_property(
			building, "rotation",
			building.rotation + PI / 2, 3
	).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(6).timeout
	building.queue_free()
