extends Area2D



func _ready() -> void:
	await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.5, 300), 0.3)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)
	await get_tree().create_timer(0.5).timeout
	#tween.tween_property(green_projectile, "scale", Vector2(2, 2), 0.5).set_delay(0.2)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.health = body.health - 3
