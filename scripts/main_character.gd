extends CharacterBody3D

@export var inventory_data: InventoryData

@onready var mc_head: Node3D = $mcHead
@onready var mc_standing_collision: CollisionShape3D = $mcStandingCollision
@onready var mc_crouching_collision: CollisionShape3D = $mcCrouchingCollision
@onready var head_ray: RayCast3D = $mcHead/headRay
@onready var journal_interface: Control = $UI/JournalInterface
@onready var quick_inven_interface: Control = $UI/QuickInvenInterface
@onready var item_cast: RayCast3D = $mcHead/itemCast
@onready var interaction_label: Label = $UI/InteractionLabel
@onready var inventory_alert: Label = $"UI/Inventory Alert"
@onready var inventory: PanelContainer = $UI/QuickInvenInterface/inventory
@onready var inventory2: PanelContainer = $UI/JournalInterface/inventory

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
var can_rotate:bool = true
var item_selected:SlotData
var item_index:int = -1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity.y = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_rotate:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		mc_head.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		mc_head.rotation.x = clamp(mc_head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		
	if event.is_action_pressed("Pickup") and item_cast.is_colliding():
		add_item()
	
	if event.is_action_pressed("Item1"):
		for i in range (4) :
			inventory.unselect_index(i)
		if (item_index==0) :
			item_index = -1
			item_selected = null
			return
		inventory.select_index(0)
		item_index = 0
		item_selected = inventory_data.slot_datas[0]
	
	if event.is_action_pressed("Item2"):
		for i in range (4) :
			inventory.unselect_index(i)
		if (item_index==1) :
			item_index = -1
			item_selected = null
			return
		inventory.select_index(1)
		item_index = 1
		item_selected = inventory_data.slot_datas[1]
	
	if event.is_action_pressed("Item3"):
		for i in range (4) :
			inventory.unselect_index(i)
		if (item_index==2) :
			item_index = -1
			item_selected = null
			return
		inventory.select_index(2)
		item_index = 2
		item_selected = inventory_data.slot_datas[2]
	
	if event.is_action_pressed("Item4"):
		for i in range (4) :
			inventory.unselect_index(i)
		if (item_index==3) :
			item_index = -1
			item_selected = null
			return
		inventory.select_index(3)
		item_index = 3
		item_selected = inventory_data.slot_datas[3]

func add_item() -> void:
	var object:PickUpable = item_cast.get_collider()
	
	if object is PickUpable:
		var new_item_name = object.slot_data.item_data.name
		
		var item_to_update:SlotData = inventory_data.items.get(new_item_name)
		if item_to_update:
			if item_to_update.item_data.stackable:
				if item_to_update.quantity + object.slot_data.item_data.quantity <= 99 :
					item_to_update.quantity += object.slot_data.item_data.quantity
					populate_item()
					object.queue_free()
					return
				else :
					item_error("Item Full")
					return
		
		var array_slot = inventory_data.slot_datas
		for slot_index in array_slot.size():
			if not array_slot[slot_index] :
				array_slot[slot_index] = object.slot_data
				object.queue_free()
				populate_item()
				return
		item_error("No More Slot")

func populate_item() -> void:
	inventory.populate_item_grid(inventory_data)
	inventory2.populate_item_grid(inventory_data)

func item_error(message:String) :
	inventory_alert.text = message
	inventory_alert.show()
	await get_tree().create_timer(2).timeout
	inventory_alert.hide()
	

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
	
	if Input.is_action_just_pressed("Inventory") :
		if journal_interface.visible :
			journal_interface.hide()
			quick_inven_interface.show()
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			can_rotate = true
		else :
			journal_interface.show()
			quick_inven_interface.hide()
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
			can_rotate = false
	
	if item_cast.is_colliding():
		if not interaction_label.visible:
			interaction_label.visible = true
	else:
		if  interaction_label.visible:
			interaction_label.visible = false

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
