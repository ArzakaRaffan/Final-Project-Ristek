extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var nav: NavigationAgent3D = $Navigate
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var mouse_sensibility = 1200
@export var ladder_height_subtract = 1
var node_MC # Ini diganti sesuai nama node MC-nya
var node_POS # Ini diganti mark3d posisi awal monsternya
var chasing = false


enum PLAYER_MODES {
	WALK
}
var current_mode := PLAYER_MODES.WALK

var tween

func _ready():
	node_MC = get_parent().get_node("mainCharacter") #ganti di sini
	node_POS = get_parent().get_node("EnemyDefaultPos")

func _physics_process(delta):
	match current_mode:
		PLAYER_MODES.WALK:
			walk_process(delta)

func walk_process(delta):
	var direction = Vector3()
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if chasing:
		look_at(node_MC.position + Vector3(0,1,0), Vector3.UP)
		
		nav.target_position = node_MC.position
		
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction*SPEED, delta)
	else :
		nav.target_position = node_POS.position
		
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction*SPEED, delta)
	

	move_and_slide()

func _on_jump_scare_area_body_entered(body: Node3D) -> void:
	if body == node_MC:
		get_tree().change_scene_to_file("res://scenes/jumpscare.tscn")

func _on_chasing_area_body_entered(body: Node3D) -> void:
	if body == node_MC:
		chasing = true

func _on_chasing_area_body_exited(body: Node3D) -> void:
	if body == node_MC:
		chasing = false
