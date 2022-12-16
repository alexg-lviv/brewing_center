# main player script, movement, hp, and so checked
extends CharacterBody2D

var moveSpeed : int = 250
var vel : Vector2 = Vector2()


@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	vel = Vector2()
	# INPUTS AND MOVEMENT
	if Input.is_action_pressed("move_up"):
		AnimPlayer.play("up")
		vel.y -= 1
	
	if Input.is_action_pressed("move_down"):
		AnimPlayer.play("down")
		vel.y += 1
	
	if Input.is_action_pressed("move_left"):
		AnimPlayer.play("left")
		vel.x += -1
	
	if Input.is_action_pressed("move_right"):
		AnimPlayer.play("right")
		vel.x += 1
	
	set_velocity(vel * moveSpeed)
	move_and_slide()
	velocity
