extends KinematicBody

#Movement Calculations
export var gravity = Vector3.DOWN * 10
export var speed = 4

var direction = Vector3()
var velocity = Vector3()
var facingdir = 0

#Sound Variables
var iswalking = false
var walkSndTimer = 0
var leftstep = false
var step = false
export var timePerStepSound = 0.28
export var surface = 0

#GetComponenets
onready var sprite = get_node("sprite")
onready var grassL = get_node("grassL")
onready var grassR = get_node("grassR")
onready var stoneL = get_node("stoneL")
onready var stoneR = get_node("stoneR")
onready var floorL = get_node("floorL")
onready var floorR = get_node("floorR")
onready var groundray = get_node("groundray")

func _ready():
	walkSndTimer = timePerStepSound

func get_input():
	velocity.x = 0
	velocity.z = 0
	if Input.is_action_pressed("ui_up"):
		velocity.z -= speed
	if Input.is_action_pressed("ui_down"):
		velocity.z += speed
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

func _physics_process(delta):
	direction = Vector3(0, 0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1

	#Direction Calculations
	if direction.x > 0: # right
		facingdir = 1
	elif direction.x < 0: # left
		facingdir = 3
	elif direction.z > 0: # forward
		facingdir = 0
	elif direction.z < 0: # back
		facingdir = 2

	#Animate
	if direction != Vector3.ZERO:
		iswalking = true
		if facingdir == 0:
			sprite.play("f_walk")
		if facingdir == 1:
			sprite.play("r_walk")
		if facingdir == 2:
			sprite.play("b_walk")
		if facingdir == 3:
			sprite.play("l_walk")
	else:
		iswalking = false
		if facingdir == 0:
			sprite.play("f_idle")
		if facingdir == 1:
			sprite.play("r_idle")
		if facingdir == 2:
			sprite.play("b_idle")
		if facingdir == 3:
			sprite.play("l_idle")

	#Move
	velocity += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector3.UP)

	#Ground Collisions
	if groundray.is_colliding():
		var other = groundray.get_collider()
		if other.is_in_group("grass"):
			surface = 0
		if other.is_in_group("stone"):
			surface = 1
		if other.is_in_group("floor"):
			surface = 2

func _process(delta):
	#Step Sound Timer
	if iswalking:
		walkSndTimer -= delta
		if walkSndTimer <= 0:
			leftstep = !leftstep
			step = true
			walkSndTimer = timePerStepSound
	else:
		walkSndTimer = timePerStepSound
		leftstep = true

	#Play Step Sounds
	if step == true:
		#grass
		if surface == 0:
			if leftstep == true:
				grassL.play()
			else:
				grassR.play()
		#stone
		if surface == 1: 
			if leftstep == true:
				stoneL.play()
			else:
				stoneR.play()
		#floor
		if surface == 2:
			if leftstep == true:
				floorL.play()
			else:
				floorR.play()
	step = false
