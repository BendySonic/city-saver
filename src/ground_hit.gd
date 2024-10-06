extends Sprite2D

var damaged := false

func _ready() -> void:
	await get_tree().create_timer(7).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate",Color(1, 1, 1, 0), 3)
	await get_tree().create_timer(3).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if not damaged:
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("enemy"):
				print("UEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
				body.health -= 15
				damaged = true
				body.stun()
