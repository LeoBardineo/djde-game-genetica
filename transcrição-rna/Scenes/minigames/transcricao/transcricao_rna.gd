extends Node2D

@export var base_scene: PackedScene = preload("res://Scenes/minigames/transcricao/base_node.tscn")
@export var dna_length: int = 30
@export var button_error_cooldown: float = 0.25
@export var max_lives: int = 3
@export var base_time_limit: float = 2.0
@export var three_star_time_threshold: float = 12.0  
@export var two_star_time_threshold: float = 20.0    

@onready var camera: Camera2D = $Camera2D
@onready var dna_container: Node2D = $DNA_Container
@onready var rna_container: Node2D = $RNA_Container
@onready var hud: HUD = $HUD

const DNA_BASES: Array[String] = ["A", "T", "C", "G"]
const TRANSCRIPTION_MAP: Dictionary = {
	"A": "U",
	"T": "A",
	"C": "G",
	"G": "C"
}
const ACTION_TO_BASE: Dictionary = {
	"transcribe_a": "A",
	"transcribe_u": "U",
	"transcribe_c": "C",
	"transcribe_g": "G"
}
const SPACING: float = 80.0

var current_base_time_left: float = 0.0
var elapsed_time: float = 0.0
var is_game_active: bool = true
var sequence: Array[String] = []
var current_index: int = 0
var is_input_locked: bool = false
var current_lives: int = max_lives
var is_game_over: bool = false

func _ready() -> void:
	current_lives = max_lives
	current_base_time_left = base_time_limit
	camera.position.x = 0
	
	generate_dna(dna_length)
	highlight_current_dna_base()
	hud.update_hearts(current_lives)
	hud.update_timer(1.0)

func _process(delta: float) -> void:
	if not is_game_active or is_game_over:
		return
	elapsed_time += delta
	current_base_time_left -= delta
	if current_base_time_left <= 0.0:
		current_base_time_left = base_time_limit
		hud.update_timer(1.0)
		handle_mistake()
		return
	hud.update_timer(current_base_time_left / base_time_limit)

func generate_dna(length: int) -> void:
	for i in range(length):
		var base_type: String = DNA_BASES.pick_random()
		sequence.append(base_type)
		
		var dna_node: BaseNode = base_scene.instantiate() as BaseNode
		dna_container.add_child(dna_node)
		dna_node.position = Vector2(i * SPACING, 0)
		dna_node.setup(base_type, false)

func highlight_current_dna_base() -> void:
	if current_index < sequence.size():
		var current_node: BaseNode = dna_container.get_child(current_index) as BaseNode
		if current_node:
			current_node.highlight_up(-20.0)

func _unhandled_input(event: InputEvent) -> void:
	if is_game_over or not is_game_active or is_input_locked or current_index >= sequence.size():
		return

	for action in ACTION_TO_BASE.keys():
		if event.is_action_pressed(action):
			var input_base: String = ACTION_TO_BASE[action]
			var expected_rna: String = TRANSCRIPTION_MAP[sequence[current_index]]
			check_match(input_base, expected_rna)
			break

func check_match(input: String, expected: String) -> void:
	if input == expected:
		var current_dna_node: BaseNode = dna_container.get_child(current_index) as BaseNode
		if current_dna_node:
			current_dna_node.settle_down()
		
		var rna_node: BaseNode = base_scene.instantiate() as BaseNode
		rna_container.add_child(rna_node)
		rna_node.position = Vector2(current_index * SPACING, -70)
		rna_node.setup(input, true)
		rna_node.appear_and_settle(-25.0)
		current_index += 1
		move_camera()
		current_base_time_left = base_time_limit
		hud.update_timer(1.0)
		if current_index >= sequence.size():
			complete_game()
		else:
			highlight_current_dna_base()
	else:
		handle_mistake()

func handle_mistake() -> void:
	var current_dna_node: BaseNode = dna_container.get_child(current_index) as BaseNode
	if current_dna_node:
		current_dna_node.play_shake_animation(8.0, 0.25)
		
	apply_input_cooldown(button_error_cooldown)
	current_lives -= 1
	hud.update_hearts(current_lives)
	
	if current_lives <= 0:
		trigger_game_over("Sem vidas")

func apply_input_cooldown(duration: float) -> void:
	is_input_locked = true
	await get_tree().create_timer(duration).timeout
	is_input_locked = false

func move_camera() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(camera, "position:x", current_index * SPACING, 0.2).set_trans(Tween.TRANS_SINE)

func complete_game() -> void:
	is_game_active = false
	
	var stars: int = 1
	if elapsed_time <= three_star_time_threshold:
		stars = 3
	elif elapsed_time <= two_star_time_threshold:
		stars = 2
	hud.show_victory(stars, elapsed_time)

func trigger_game_over(reason: String = "Fim de jogo") -> void:
	is_game_active = false
	is_game_over = true
	hud.show_game_over(reason)
