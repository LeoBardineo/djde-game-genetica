extends Node2D

@export var base_scene: PackedScene = preload("res://Scenes/minigames/transcricao/base_node.tscn")
@export var dna_length: int = 30
@export var button_error_cooldown: float = 0.25

const DNA_BASES = ["A", "T", "C", "G"]
const TRANSCRIPTION_MAP = {
	"A": "U",
	"T": "A",
	"C": "G",
	"G": "C"
}
const ACTION_TO_BASE = {
	"transcribe_a": "A",
	"transcribe_u": "U",
	"transcribe_c": "C",
	"transcribe_g": "G"
}
const SPACING = 80

var sequence = []
var current_index = 0
var is_input_locked: bool = false

@onready var camera = $Camera2D
@onready var dna_container = $DNA_Container
@onready var rna_container = $RNA_Container

func _ready():
	generate_dna(dna_length)
	highlight_current_dna_base()

func highlight_current_dna_base() -> void:
	if current_index < sequence.size():
		var current_node = dna_container.get_child(current_index) as BaseNode
		if current_node:
			current_node.highlight_up(-20.0)

func generate_dna(length: int):
	for i in range(length):
		var base_type = DNA_BASES.pick_random()
		sequence.append(base_type)
		
		var dna_node = base_scene.instantiate() as BaseNode
		dna_container.add_child(dna_node)
		dna_node.position = Vector2(i * SPACING, 0)
		dna_node.setup(base_type, false)

func _unhandled_input(event):
	if is_input_locked or current_index >= sequence.size():
		return

	for action in ACTION_TO_BASE.keys():
		if event.is_action_pressed(action):
			var input_base = ACTION_TO_BASE[action]
			var expected_rna = TRANSCRIPTION_MAP[sequence[current_index]]
			check_match(input_base, expected_rna)
			break

func check_match(input, expected):
	if input == expected:
		var current_dna_node = dna_container.get_child(current_index) as BaseNode
		if current_dna_node:
			current_dna_node.settle_down()
		
		var rna_node = base_scene.instantiate() as BaseNode
		rna_container.add_child(rna_node)
		rna_node.position = Vector2(current_index * SPACING, -70)
		rna_node.setup(input, true)
		# rna_node.play_sucess_animation()
		rna_node.appear_and_settle(-25.0)
		
		current_index += 1
		move_camera()
		
		highlight_current_dna_base()
	else:
		var current_dna_node = dna_container.get_child(current_index) as BaseNode
		if current_dna_node:
			current_dna_node.play_shake_animation(8.0, 0.25)
		apply_input_cooldown(button_error_cooldown)
		print("Errou a base, era para ser " + expected)

func apply_input_cooldown(duration: float) -> void:
	is_input_locked = true
	await get_tree().create_timer(duration).timeout
	is_input_locked = false

func move_camera():
	var tween = create_tween()
	tween.tween_property(camera, "position:x", current_index * SPACING, 0.2).set_trans(Tween.TRANS_SINE)
