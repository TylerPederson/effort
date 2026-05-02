extends CharacterBody3D


signal perform_attack
signal perform_attack_alternative
signal perform_sprint
signal stop_attack_alternative
signal stop_sprint

const SPEED = 400.0
const JUMP_VELOCITY = 4.5

#///////////////////pauseMenu//////////////////////
const pause_menu_scene = preload("res://PauseMenu/PauseMenu.tscn")
#///////////////////////////////////////////////////

@onready var sprint_component: SprintComponent = $Sprint_Component
@onready var inventory_controller: InventoryController = $"Inventory Controller/CanvasLayer/Inventory UI"
@onready var armor_component: ArmorComponent = $Armor_Component
@onready var attack_component: AttackComponent = $Attack_Component
@onready var weapon_component: WeaponComponent = %WeaponHolder/Weapon_Component
@onready var basic_hud: Basic_HUD = $Basic_HUD

#/////////////////////////pauseMenu//////////////////////
var pause_menu_instance = null
#/////////////////////////////////////////////////////////

#**********************julian######################
@onready var raycast = $RayCast3D 
###################################################
	

var state_machine : AnimationNodeStateMachinePlayback

# Stores the x-y direction to rotate the player look direction
var _look := Vector2.ZERO

var able_to_move = true

# mouse sensistivity should be low because it is in radians
@export var mouse_sensitivity := 0.0008
@export var min_look_boundary  = -60.0
@export var max_look_boundary  = 10.0

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot

@onready var armature: Node3D = $Hero_Rig/Armature
@onready var animation_tree: AnimationTree = $AnimationTree

func get_facing_direction() -> Basis:
	return horizontal_pivot.global_transform.basis


# To properly move, the player camera needs the mouse to be captured
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	basic_hud.display_info("Go forth with Effort!", 2.0)
	able_to_move = true
	state_machine = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state_machine.travel("jump")

	# Moves based on input keys and facing direction. Smoothly stops if no key is pressed
	var direction := get_movement_direction()
	var move_speed = sprint_component.apply_sprint(SPEED, delta)
	if direction and able_to_move:
		velocity.x = direction.x * move_speed * delta
		velocity.z = direction.z * move_speed * delta
		if is_on_floor() and velocity.y < 0.1:
			state_machine.travel("run")
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * delta)
		if is_on_floor() and velocity.y < 0.1:
			state_machine.travel("idle")
	
	if velocity.y < 0:
		if state_machine.get_current_node() == "jump":
			state_machine.travel("fall")
		else:
			state_machine.travel("falling")

	
	
	move_and_slide()


func abort_other_oneshots():
	animation_tree["parameters/attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	animation_tree["parameters/grab/request"] =  AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	animation_tree["parameters/cheer/request"] =  AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	animation_tree["parameters/hurt/request"] =  AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT


func _unhandled_input(event: InputEvent) -> void:
	
	#///////////////////////pauseMenuCode///////////////////////////////////
	if event.is_action_pressed("ui_cancel"):
		if pause_menu_instance == null:
			pause_menu_instance = pause_menu_scene.instantiate()
			%InfoScreens.add_child(pause_menu_instance)
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return

		#if pause is opnen then close it
		if pause_menu_instance != null:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pause_menu_instance.queue_free()
			pause_menu_instance = null
			return

		# if inventory is open then close it
		if inventory_controller.visible:
			inventory_controller.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return

		#or just open pause menu
		
		#pause_menu_instance = pause_menu_scene.instantiate()
		#add_child(pause_menu_instance)
		#pause_menu_instance.tree_exited.connect(func(): pause_menu_instance = null)
		#get_tree().paused = true
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#return
#///////////////////////////////////////////////////////////////////////
	
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look += -event.relative * mouse_sensitivity
		
		if event.is_action_pressed("combat_attack"):
			if not inventory_controller.equipped_items["weapon_melee"] == null:
				perform_attack.emit()
				

		if event.is_action_pressed("combat_alternative"):
			if not inventory_controller.equipped_items["weapon_melee"] == null:
				perform_attack_alternative.emit()
		if event.is_action_released("combat_alternative"):
			stop_attack_alternative.emit()
		if event.is_action_pressed("move_sprint"):
			perform_sprint.emit()
		if event.is_action_released("move_sprint"):
			stop_sprint.emit()
		
		if event.is_action_pressed("interact"):
			abort_other_oneshots()
			animation_tree["parameters/grab/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
#///////////////////////////Removed to make pause work////////////////
#	if event.is_action_pressed("ui_cancel"):
#		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
#			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#		else:
#			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#///////////////////////////////////////////////////////////////////////

	
	if event.is_action_pressed("ui_text_caret_line_start"):
		get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")

# Calculates the desired movement direction based on input direction and which way the player is facing
func get_movement_direction() -> Vector3:
	# global movement direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_vector := Vector3(input_dir.x, 0, input_dir.y).normalized()
	# transforms movement to be based on the horizontal facing direction
	var direction := horizontal_pivot.global_transform.basis * input_vector
	return direction


# rotates pivot nodes to store how much the player has rotated based on how much
# the mouse moves  each from
func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	# Prevent vertical look direction from looking up or down too much
	vertical_pivot.rotation.x = clampf(
		 vertical_pivot.rotation.x,
		 deg_to_rad(min_look_boundary),
		 deg_to_rad(max_look_boundary)
	)
	
	# Spring arm only needs to copy what the vertical pivot has already stored.
	$SpringArm3D.global_transform = vertical_pivot.global_transform
	
	# By this point, "used" all the difference accumulated in _look since last frame, reset for next accumulation
	_look = Vector2.ZERO
	

func _on_equip_change(slot: String, equip_data) -> void:
	match slot:
		"armor_helm", "armor_body", "armor_feet":
			armor_component.update_equipment(inventory_controller.equipped_items)
		"weapon_ranged":
			weapon_component.update_weapon(inventory_controller.equipped_items)
			attack_component._refresh_weapon()
		"weapon_melee":
			weapon_component.update_weapon(inventory_controller.equipped_items)
			attack_component._refresh_weapon()
			
			for child in %WeaponMeshHolder.get_children():
				child.visible = false
			
			if !inventory_controller.equipped_items["weapon_melee"]:
				return
			
			print(inventory_controller.equipped_items["weapon_melee"].item_name)
			match (inventory_controller.equipped_items["weapon_melee"].item_name):
				"Steel Axe":
					%Mesh_SteelAxe.visible = true
				"Iron Sword":
					%Mesh_IronSword.visible = true
				"Crossbow":
					%Mesh_Crossbow.visible = true
				"Wooden Bow":
					%Mesh_Bow.visible = true
				"Katana":
					%Mesh_Katana.visible = true
				_:
					print("unset everything")


func _on_health_component_death() -> void:
	able_to_move = false
	basic_hud.display_info("You have died...", 3.0)
	abort_other_oneshots()
	animation_tree["parameters/die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await get_tree().create_timer(3.0).timeout
	
	get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")


func attack_animation(time: Variant) -> void:
	abort_other_oneshots()
	#Adjust the time scale for the animation (frames per second / frames_used * cooldown)
	#This will make the animation player faster/slower depending on the cooldown of attack
	animation_tree["parameters/attack_timescale/scale"] = 24.0 / (20.0 * time)
	animation_tree["parameters/attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func alternative_attack_animation(flag: bool, total: float) -> void:
	if !flag:
		if !is_on_floor():
			return
		abort_other_oneshots()
		animation_tree["parameters/cheer/request"] =  AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func hurt_animation():
	abort_other_oneshots()
	animation_tree["parameters/hurt/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
