# main player script, movement, hp, and so checked
extends CharacterBody2D

var moveSpeed : int = 250
var vel : Vector2 = Vector2.ZERO


@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	vel = Vector2()
	# INPUTS AND MOVEMENT
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	
	if Input.is_action_pressed("move_left"):
		vel.x += -1
	
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	
	
	handle_anims()
	set_velocity(vel * moveSpeed)
	move_and_slide()
	velocity

func handle_anims():
	if vel.x == 1:
		AnimPlayer.play("right")
	elif vel.x == -1:
		AnimPlayer.play("left")
	elif vel.y == -1:
		AnimPlayer.play("up")
	elif vel.y == 1:
		AnimPlayer.play("down")
	elif vel == Vector2.ZERO:
		AnimPlayer.play("idle")
