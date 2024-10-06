extends CharacterBody2D

signal health_changed(health: float)
signal dashed
signal lasered
signal grounded
signal greened
signal moved

const LASER_COOLDOWN = 10
const GROUND_HIT_COOLDOWN = 10
const GREEN_PROJECTILE_COOLDOWN = 10
const ULTIMATE_ATTACK_COOLDOWN = 40
const SPEED = 400.0

var is_moving := false:
	set(value):
		if not is_moving and value:
			deform()
		elif is_moving and not value:
			form()
		if value:
			moved.emit()
		is_moving = value
var is_mouse_hold := false:
	set(value):
		is_moving = value
		is_mouse_hold = value
		
var dash_bonus := 1.0
var can_dash := true

var can_laser := true
var is_laser_on := false
var laser_width := 1.0

var can_ground_hit := true
var is_ground_hit_on := false

var can_green_projectile := true
var is_green_projectile_on := false

var can_ultimate_attack := false
var is_ultimate_attack_on := false

@export var sprite: Sprite2D
@export var animation: AnimationPlayer
@export var laser: RayCast2D
@export var laser_particles: CPUParticles2D
@export var explosion_particles: CPUParticles2D

@onready var ground_hit_scene: PackedScene = preload("res://src/ground_hit.tscn")
@onready var green_projectile_scene: PackedScene = preload("res://src/green_projectile.tscn")

@export var health := 3:
	set(value):
		health = value
		health_changed.emit(health)
var is_invincible := false
var is_tutorial := false:
	set(value):
		if value:
			$Battle.stop()
		is_tutorial = value

func _ready() -> void:
	if is_tutorial:
		$Battle.stop()
	else:
		$Battle.play()
	animation.play("fly")
	await get_tree().create_timer(1).timeout
	var time = ULTIMATE_ATTACK_COOLDOWN
	var bar = get_parent().get_node("CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer/Five")
	bar.value = bar.min_value
	while time > 0:
		time -= 1
		bar.value += 1
		await get_tree().create_timer(1).timeout
	can_ultimate_attack = true

func _physics_process(delta: float) -> void:
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	if is_ground_hit_on:
		pass
		#hit_ground()
	elif is_green_projectile_on:
		pass
	elif is_ultimate_attack_on:
		pass
	else:
		move(direction)
	
	set_laser()
	move_and_slide()

func move(direction: Vector2):
	if (get_global_mouse_position() - global_position).length() > 25 and dash_bonus > 1.0 and not is_moving:
		velocity = direction * SPEED * dash_bonus * 1.2
	
	if (
			((get_global_mouse_position() - global_position).length() > 25 and is_mouse_hold and is_moving)
			or ((get_global_mouse_position() - global_position).length() > 80  and is_mouse_hold and not is_moving)
	):
		is_moving = true
		velocity = direction * SPEED * dash_bonus
		
		sprite.look_at(get_global_mouse_position())
		#sprite.rotation = move_toward(sprite.rotation, (direction).angle() - 0.1, 0.1)
	else:
		velocity = velocity.move_toward(Vector2(0, 0), SPEED)
		is_moving = false

func set_laser():
	laser.look_at(get_global_mouse_position())
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		is_mouse_hold = event.is_pressed()
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		dash()
	elif Input.is_action_just_pressed("laser_attack") and can_laser:
		can_laser = false
		start_laser()
	elif Input.is_action_just_pressed("ground_hit") and can_ground_hit:
		can_ground_hit = false
		start_ground_hit()
	elif Input.is_action_just_pressed("green_projectile") and can_green_projectile:
		can_green_projectile = false
		start_green_projectile()
	elif Input.is_action_just_pressed("ultimate_attack") and can_ultimate_attack and not is_tutorial:
		can_ultimate_attack = false
		start_ultimate_attack()

func dash():
	is_invincible = true
	dash_bonus = 4.0
	if not is_moving:
		sprite.look_at(get_global_mouse_position())
		deform()
	while dash_bonus >= 1.0:
		await get_tree().create_timer(0.02).timeout
		dash_bonus -= 0.25
	if not is_moving:
		form()
	is_invincible = false
	dashed.emit()
	await get_tree().create_timer(1).timeout
	can_dash = true

func start_laser():
	var tween1 = get_tree().create_tween()
	tween1.tween_property($Laser1, "volume_db", -10.0, 0.5)
	await get_tree().create_timer(0.5).timeout
	$Laser1.play()
	is_laser_on = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "laser_width", 15.0, 0.2)
	tween.tween_property(self, "laser_width", 5.0, 1.5)
	tween.tween_property(self, "laser_width", 15.0, 1.5)
	tween.tween_property(self, "laser_width", 0.0, 1)
	tween.tween_property($Laser1, "volume_db", -50.0, 1)
	await get_tree().create_timer(4).timeout
	is_laser_on = false
	laser_particles.emitting = false
	await get_tree().create_timer(1).timeout
	$Laser1.stop()
	await get_tree().create_timer(1).timeout
	explosion_particles.emitting = true
	$Explosion2.play()
	
	lasered.emit()
	
	var time = LASER_COOLDOWN
	var bar = get_parent().get_node("CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer/One")
	bar.value = bar.min_value
	while time > 0:
		time -= 1
		bar.value += 1
		await get_tree().create_timer(1).timeout
	
	can_laser = true

func start_ground_hit():
	is_invincible = true
	is_ground_hit_on = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2(0, -1500), 0.3)
	tween.tween_property(self, "velocity", Vector2(0, 3500), 0.25).set_delay(0.1)
	await get_tree().create_timer(0.4).timeout
	$Explosion2.play()
	explosion_particles.emitting = true
	await get_tree().create_timer(0.4).timeout
	explosion_particles.emitting = true
	await get_tree().create_timer(0.2).timeout
	is_ground_hit_on = false
	await get_tree().create_timer(0.3).timeout
	is_invincible = false
	
	grounded.emit()

func start_green_projectile():
	velocity = Vector2(0, 0)
	is_green_projectile_on = true
	for i in range(3):
		$Explosion2.play()
		var green_projectile = green_projectile_scene.instantiate()
		green_projectile.global_position = global_position
		green_projectile.scale = Vector2(0.1, 0.1)
		get_parent().add_child(green_projectile)
		var tween = get_tree().create_tween()
		tween.tween_property(green_projectile, "scale", Vector2(0.05, 300), 0.3)
		tween.tween_property(green_projectile, "scale", Vector2(0.1, 300), 0.1)
		#tween.tween_property(green_projectile, "scale", Vector2(2, 2), 0.5).set_delay(0.2)
		var local_mouse_position := to_local(get_global_mouse_position())
		var enemy_position = get_global_mouse_position()
		(
			tween.tween_property(green_projectile, "global_position", green_projectile.global_position + local_mouse_position.normalized() * 500, 1)
			.set_trans(Tween.TRANS_EXPO)
		)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1).timeout
	is_green_projectile_on = false
	print("GREEN")
	greened.emit()
	
	var time = GREEN_PROJECTILE_COOLDOWN
	var bar = get_parent().get_node("CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer/Three")
	bar.value = bar.min_value
	while time > 0:
		time -= 1
		bar.value += 1
		await get_tree().create_timer(1).timeout
	
	can_green_projectile = true

func start_ultimate_attack():
	velocity = Vector2(0, 0)
	is_ultimate_attack_on = true
	#$UltimateAttack.play()
	var tween2 = get_tree().create_tween()
	tween2.tween_property($Battle, "volume_db", -15, 3).set_trans(Tween.TRANS_CUBIC)
	$UltimateAttackAnimation.play("show")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(1700, 800), 3).set_trans(Tween.TRANS_CUBIC)
	await $UltimateAttackAnimation.animation_finished
	var tween4 = get_tree().create_tween()
	tween4.tween_property($Battle, "volume_db", 0, 1).set_trans(Tween.TRANS_CUBIC)
	$UltimateAnimation.play("attack")
	$UltimateAttackAnimation.play("hide")
	
	if not is_tutorial:
		get_parent().enemy.health -= 60
		get_parent().enemy.stun()
	await get_tree().create_timer(1.5).timeout
	var tween3 = get_tree().create_tween()
	tween3.tween_property($Battle, "volume_db", -5, 1).set_trans(Tween.TRANS_CUBIC)
	is_ultimate_attack_on = false
	
	var time = ULTIMATE_ATTACK_COOLDOWN
	var bar = get_parent().get_node("CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer/Five")
	bar.value = bar.min_value
	while time > 0:
		time -= 1
		bar.value += 1
		await get_tree().create_timer(1).timeout
	can_ultimate_attack = true

func deform():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.4, 0.75), 0.1)
	animation.play("reset")

func form():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.6, 1), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
	await get_tree().create_timer(0.15).timeout
	animation.play("fly")

func _draw() -> void:
	if is_laser_on:
		if laser.is_colliding():
			draw_line(Vector2(0, 0), to_local(laser.get_collision_point()) - Vector2(0, 20), Color.RED, laser_width)
			laser_particles.emitting = true
			laser_particles.global_position = laser.get_collision_point() - Vector2(0, 20)
			if laser.get_collider().is_in_group("enemy"):
				print("WWTH")
				laser.get_collider().health = laser.get_collider().health - (0.08)
		else:
			laser_particles.emitting = false
			draw_line(Vector2(0, 0), to_local(get_global_mouse_position()).normalized() * 2000, Color.RED, laser_width)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if is_ground_hit_on and body.is_in_group("floor"):
		$Explosion1.play()
		var ground_hit = ground_hit_scene.instantiate()
		
		ground_hit.z_index = 1
		ground_hit.global_position = global_position + Vector2(0, 15)
		get_parent().add_child(ground_hit)
		
		var time = GROUND_HIT_COOLDOWN
		var bar = get_parent().get_node("CanvasLayer/Control/MarginContainer2/HBoxContainer/HBoxContainer/Two")
		bar.value = bar.min_value
		while time > 0:
			time -= 1
			bar.value += 1
			await get_tree().create_timer(1).timeout
		can_ground_hit = true
