extends Node2D
class_name BaseNode

@onready var texture_rect: TextureRect = $TextureRect

const BASE_TEXTURES: Dictionary = {
	"A": preload("res://Sprites/minigames/transcricao/letras/A_LARANJA_FRONTAL.png"),
	"T": preload("res://Sprites/minigames/transcricao/letras/A_ROSA_FRONTAL.png"),
	"C": preload("res://Sprites/minigames/transcricao/letras/C_VERDE_FRONTAL.png"),
	"G": preload("res://Sprites/minigames/transcricao/letras/G_ROXO_FRONTAL.png"),
	"U": preload("res://Sprites/minigames/transcricao/letras/U_ROSA_FRONTAL.png")
}

var base_type: String = ""
var is_transcribed: bool = false
var base_initial_x: float = 0.0
var base_initial_y: float = 0.0
var shake_tween: Tween

func setup(type: String, transcribed: bool = false) -> void:
	base_type = type
	is_transcribed = transcribed
	
	if not is_inside_tree():
		await ready
	
	base_initial_x = position.x
	base_initial_y = position.y
	_apply_visuals()

func _apply_visuals() -> void:
	if not BASE_TEXTURES.has(base_type):
		push_warning("Textura não encontrada para a base: %s" % base_type)
		return
	
	texture_rect.texture = BASE_TEXTURES[base_type]
	
	if is_transcribed:
		texture_rect.modulate = Color(0.85, 0.85, 0.85, 1.0)
	else:
		texture_rect.modulate = Color.WHITE

func highlight_up(offset_y: float = -20.0, duration: float = 0.15) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", base_initial_y + offset_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func settle_down(duration: float = 0.15) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", base_initial_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func appear_and_settle(spawn_offset_y: float = -20.0, duration: float = 0.15) -> void:
	position.y = base_initial_y + spawn_offset_y
	modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", base_initial_y, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, duration)

func play_sucess_animation() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func play_shake_animation(shake_offset: float = 6.0, shake_duration: float = 0.2) -> void:
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
		position.x = base_initial_x
	
	var step_time = shake_duration / 5.0
	shake_tween = create_tween()
	shake_tween.tween_property(self, "position:x", base_initial_x - shake_offset, step_time)
	shake_tween.tween_property(self, "position:x", base_initial_x + shake_offset, step_time)
	shake_tween.tween_property(self, "position:x", base_initial_x - (shake_offset / 2.0), step_time)
	shake_tween.tween_property(self, "position:x", base_initial_x + (shake_offset / 2.0), step_time)
	shake_tween.tween_property(self, "position:x", base_initial_x, step_time)
	
	const FLASH_RED_RATIO: float = 0.75
	const FLASH_RESTORE_RATIO: float = 1.0 - FLASH_RED_RATIO
	
	var flash_tween = create_tween()
	flash_tween.tween_property(texture_rect, "modulate", Color(2.0, 0.4, 0.4), shake_duration * FLASH_RED_RATIO)
	flash_tween.tween_property(texture_rect, "modulate", Color.WHITE if not is_transcribed else Color(0.85, 0.85, 0.85), shake_duration * FLASH_RESTORE_RATIO)
