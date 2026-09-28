extends KinematicBody2D

const UP= Vector2(0,-1)
const GRAVITY= 60
const JUMP_SPEED=-1200

var motion=Vector2() 

onready var jump=$jump

func _physics_process(_delta):
	motion.y+=GRAVITY
		
	if is_on_floor():
		$run.disabled = false
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_SPEED
			jump.play()
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite.play("duck")
			$run.disabled = true
		else:
			$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("jump")
	
	motion= move_and_slide(motion,UP)



	
	
