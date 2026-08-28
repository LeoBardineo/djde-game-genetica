extends Node2D
class_name BaseNode

@onready var label: RichTextLabel = $RichTextLabel
@onready var panel: Panel = $Panel

const BASE_COLORS = {
	"A": Color("#ff5555"),
	"U": Color("#ffb86c"),
	"T": Color("#f1fa8c"),
	"C": Color("#8be9fd"),
	"G": Color("#50fa7b")
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
	label.text = type
	_apply_visuals()

func _apply_visuals() -> void:
	if not BASE_COLORS.has(base_type):
		return
		
	var final_color = BASE_COLORS[base_type]
	
	if is_transcribed:
		final_color = final_color.darkened(0.2)

	var new_stylebox = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	new_stylebox.bg_color = final_color
	panel.add_theme_stylebox_override("panel", new_stylebox)

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
	
	var red_time_percentage = 0.75
	var white_time_percentage = red_time_percentage - 1
	var flash_tween = create_tween()
	flash_tween.tween_property(panel, "modulate", Color(2.0, 0.3, 0.3), shake_duration * red_time_percentage)
	flash_tween.tween_property(panel, "modulate", Color.WHITE, shake_duration * white_time_percentage)
