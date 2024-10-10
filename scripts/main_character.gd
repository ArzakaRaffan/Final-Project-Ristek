extends CharacterBody3D

@onready var mc_head: Node3D = $mcHead
@onready var mc_standing_collision: CollisionShape3D = $mcStandingCollision
@onready var mc_crouching_collision: CollisionShape3D = $mcCrouchingCollision
@onready var head_ray: RayCast3D = $mcHead/headRay

var speed = 3.0
const JUMPING_SPEED = 2.5
const SPRINT_JUMP_SPEED = 4
const WALKING_SPEED = 3.0
const SPRINTING_SPEED = 4.5
const CROUCHING_SPEED = 2.0
const CROUCH_DEPTH = -0.8
const JUMP_VELOCITY = 3.0

const SENSITIVITY = 0.5
const LERP_SPEED = 10.0 

var is_sprinting = false
var can_sprint = true
var flashLightOn = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity.y = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		mc_head.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		mc_head.rotation.x = clamp(mc_head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Flashlight"):
		if flashLightOn:
			$mcHead/SpotLight3D.spot_range = 50
			$mcHead/SpotLight3D.spot_angle = 65
			$mcHead/SpotLight3D.spot_attenuation = 1.6
			$mcHead/SpotLight3D.light_color = "#7d7d7d"
			flashLightOn = false
		else:
			$mcHead/SpotLight3D.spot_range = 40
			$mcHead/SpotLight3D.spot_angle = 50
			$mcHead/SpotLight3D.spot_attenuation = 1
			$mcHead/SpotLight3D.light_color = "#c6c6c6"
			flashLightOn = true
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()

	if not is_sprinting and Global.sprint_value < 100:
		Global.sprint_value += 20 * delta
		if Global.sprint_value >= 100:
			Global.sprint_value = 100
			can_sprint = true
			
	if not is_on_floor():
		if is_sprinting:
			Global.sprint_value -= 0.75
			if Global.sprint_value <= 0:
				Global.sprint_value = 0
				is_sprinting = false 
				can_sprint = false
			speed = SPRINT_JUMP_SPEED
		else:
			speed = JUMPING_SPEED
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_on_floor():
		# Handle crouch
		if Input.is_action_pressed("Crouch"):
			mc_standing_collision.disabled = true
			mc_crouching_collision.disabled = false
			speed = CROUCHING_SPEED
			mc_head.position.y = lerp(mc_head.position.y, 1.8 + CROUCH_DEPTH, delta * LERP_SPEED)
			is_sprinting = false
		else:
			mc_standing_collision.disabled = false
			mc_crouching_collision.disabled = true
			

			if Input.is_action_pressed("Sprint") and Global.sprint_value == 100 and can_sprint:
				is_sprinting = true
			if is_sprinting:
				Global.sprint_value -= 0.75
				speed = SPRINTING_SPEED
				if Global.sprint_value <= 0:
					Global.sprint_value = 0
					is_sprinting = false
					can_sprint = false
			else:
				speed = WALKING_SPEED

		mc_head.position.y = lerp(mc_head.position.y, 1.4, delta * LERP_SPEED)

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
