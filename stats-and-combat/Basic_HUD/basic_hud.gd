extends Control
class_name Basic_HUD

@onready var hp_bar: ProgressBar = $HP_Bar
@onready var stamina_bar: ProgressBar = $Stamina_Bar
@onready var charge_bar: ProgressBar = $Charge_Bar
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var buff_label: Label = $BuffLabel
@onready var passive1: TextureRect = $Passive1
@onready var passive2: TextureRect = $Passive2
@onready var passive3: TextureRect = $Passive3
@onready var num_of_passives 
@onready var passive_array
@onready var hp_ratio
@onready var stamina_ratio
@onready var empty_passive = load("res://stats-and-combat/Basic_HUD/Sprites/empty_passive.png")
@onready var damage_boost = load("res://stats-and-combat/Basic_HUD/Sprites/damage_boost.png")
@onready var damage_cooldown = load("res://stats-and-combat/Basic_HUD/Sprites/damage_cooldown.png")
@onready var ratio_armor = load("res://stats-and-combat/Basic_HUD/Sprites/ratio_armor.png")
@onready var flat_armor = load("res://stats-and-combat/Basic_HUD/Sprites/flat_armor.png")
@onready var health_increase = load("res://stats-and-combat/Basic_HUD/Sprites/health_increase.png")
@onready var health_regen = load("res://stats-and-combat/Basic_HUD/Sprites/health_regen.png")
@onready var sprint_efficiency = load("res://stats-and-combat/Basic_HUD/Sprites/sprint_efficiency.png")
@onready var sprint_speed = load("res://stats-and-combat/Basic_HUD/Sprites/sprint_speed.png")
@onready var stamina_increase = load("res://stats-and-combat/Basic_HUD/Sprites/stamina_increase.png")
@onready var stamina_regen = load("res://stats-and-combat/Basic_HUD/Sprites/stamina_regen.png")
@onready var cooldown_bar : ProgressBar = $Cooldown_Bar
@onready var cooldown_timer : Timer = $Cooldown_Bar/Timer
@onready var health_orb : Sprite2D = $health_orb
@onready var health_mat = health_orb.material
@onready var stamina_orb : Sprite2D = $stamina_orb
@onready var stamina_mat = stamina_orb.material


func _ready() -> void:
	
	passive1.texture = empty_passive
	passive2.texture = empty_passive
	passive3.texture = empty_passive
	passive_array = [passive1, passive2, passive3]
	num_of_passives = 0
	hp_ratio = 1
	stamina_ratio = 1
	health_mat.set_shader_parameter("health", 0)
	hp_bar.max_value = 100
	hp_bar.value = 100
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	stamina_mat.set_shader_parameter("health", 0)
	info_label.text = ""
	buff_label.text = ""
	cooldown_bar.visible = false



func display_buff(text: String, duration : float = 1.5):
	buff_label.text = text
	await get_tree().create_timer(duration).timeout
	buff_label.text = ""

func display_info(text: String, duration : float = 1.5):
	info_label.text = text
	await get_tree().create_timer(duration).timeout
	info_label.text = ""
	

func _on_weapon_component_attack_started(time: Variant) -> void:
	cooldown_bar.visible = true
	cooldown_timer.start(time)
	cooldown_bar.max_value = time


func _on_health_component_health_change(current_hp: Variant, total_hp: Variant) -> void:
	hp_bar.max_value = total_hp
	hp_bar.value = current_hp
	hp_ratio =  hp_bar.value / hp_bar.max_value
	print(hp_ratio)
	health_mat.set_shader_parameter("health", hp_ratio)


func _on_stamina_component_stamina_change(current_stamina: Variant, total_stamina: Variant) -> void:
	stamina_bar.max_value = total_stamina
	stamina_bar.value = current_stamina
	stamina_ratio = stamina_bar.value / stamina_bar.max_value
	stamina_mat.set_shader_parameter("health", stamina_ratio)


func _on_attack_alternative_component_perform_active(flag: bool, amount: float) -> void:
	charge_bar.visible = flag
	charge_bar.max_value = amount

func _on_attack_alternative_component_perform_charge_change(amount: Variant) -> void:
	charge_bar.value = amount


	#Collectible.TYPE.HP_REGEN,
	#Collectible.TYPE.HP_BOOST,
	#Collectible.TYPE.STAMINA_REGEN,
	#Collectible.TYPE.STAMINA_BOOST,
	#Collectible.TYPE.BONUS_FLAT_ARMOR,
	#Collectible.TYPE.BONUS_RATIO_ARMOR,
	#Collectible.TYPE.SPRINT_USE_RATIO,
	#Collectible.TYPE.SPRINT_SPEED_BOOST,
	#Collectible.TYPE.DAMAGE_BOOST,
	#Collectible.TYPE.DAMAGE_COOLDOWN

func _on_power_up_collect(type: Collectible.TYPE):
	print("signal")
	print("collected thing " + str(type))
	if num_of_passives < 3:
		match str(type):
			"0":
				passive_array[num_of_passives].texture = health_regen
				num_of_passives = num_of_passives + 1
			"1":
				passive_array[num_of_passives].texture = health_increase
				num_of_passives = num_of_passives + 1
			"2":
				passive_array[num_of_passives].texture = stamina_regen
				num_of_passives = num_of_passives + 1
			"3":
				passive_array[num_of_passives].texture = stamina_increase
				num_of_passives = num_of_passives + 1
			"4":
				passive_array[num_of_passives].texture = flat_armor
				num_of_passives = num_of_passives + 1
			"5":
				passive_array[num_of_passives].texture = ratio_armor
				num_of_passives = num_of_passives + 1
			"6":
				passive_array[num_of_passives].texture = sprint_efficiency
				num_of_passives = num_of_passives + 1
			"7":
				passive_array[num_of_passives].texture = sprint_speed
				num_of_passives = num_of_passives + 1
			"8":
				passive_array[num_of_passives].texture = damage_boost
				num_of_passives = num_of_passives + 1
			"9":
				passive_array[num_of_passives].texture = damage_cooldown
				num_of_passives = num_of_passives + 1
		
		

func _process(_delta):
	if cooldown_timer.time_left > 0:
		cooldown_bar.value = cooldown_timer.wait_time - cooldown_timer.time_left


func _on_timer_timeout() -> void:
	cooldown_bar.visible = false
