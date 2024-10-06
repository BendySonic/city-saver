extends CharacterBody2D

signal health_changed(health: float)

enum State {INTRO, IDLE, ATTACK, STUNNED, BLOW, WALK}

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

@export var health: float = 250.0:
	set(value):
		health = value
		health_changed.emit(health)
		if health <= 0:
			$AnimationPlayer.play("ko")
			await get_tree().create_timer(2).timeout
			queue_free()
		#print("Change to ", value)

var state: State = State.INTRO:
	set(value):
		match value:
			State.IDLE:
				$AnimationPlayer.play("idle")
				state = value
			State.WALK:
				$AnimationPlayer.play("walk")
				state = value
				can_walk = false
				await $AnimationPlayer.get_tree().create_timer(randi_range(2, 3)).timeout
				can_walk = true
			State.ATTACK:
				$AnimationPlayer.play("attack")
				for body in $Area2D.get_overlapping_bodies():
					if body.is_in_group("player"):
						if not body.is_invincible:
							body.health -= 1
				state = value
				await $AnimationPlayer.animation_finished
				if state == State.ATTACK:
					$AnimationPlayer.play("idle")
					state = State.IDLE
				get_parent().destroy()
			State.BLOW:
				$AnimationPlayer.play("blow")
				state = value
				await $AnimationPlayer.animation_finished
				if state == State.BLOW:
					$AnimationPlayer.play("idle")
					state = State.IDLE
				get_parent().destroy()
			State.STUNNED:
				$AnimationPlayer.play("stunned")
				state = value
				await get_tree().create_timer(4).timeout
				if state == State.STUNNED:
					$AnimationPlayer.play("idle")
					state = State.IDLE

var can_walk := true
var direction: int

func _ready() -> void:
	state = State.INTRO
	$AnimationPlayer.play("scream")
	await $AnimationPlayer.animation_finished
	state = State.IDLE
	$AttackTimer.start()
	$BlowTimer.start()

func _physics_process(delta: float) -> void:
	#print(health)
	if state == State.IDLE and can_walk:
		#await get_tree().create_timer(1).timeout
		direction = -direction
		if not direction:
			direction = -1
		state = State.WALK
		can_walk = false
			
			
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not state == State.STUNNED:
		move_and_slide()


func _on_attack_timer_timeout() -> void:
	if not state == State.STUNNED:
		state = State.ATTACK

func _on_blow_timer_timeout() -> void:
	if not state == State.STUNNED:
		state = State.BLOW

func stun():
	state = State.STUNNED
