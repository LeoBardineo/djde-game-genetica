extends CanvasLayer
class_name HUD

@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D
@export var star_full_texture: Texture2D
@export var star_empty_texture: Texture2D

@onready var heart_icons: Array = $HeartsContainer.get_children()
@onready var game_over_panel: Panel = $GameOverPanel
@onready var title_label: RichTextLabel = $GameOverPanel/VBoxContainer/TitleLabel
@onready var final_score_label: RichTextLabel = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var time_spent_label: RichTextLabel = $GameOverPanel/VBoxContainer/TimeSpentLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var timer_circle: TextureProgressBar = $TimerCircle
@onready var star_icons: Array = $GameOverPanel/VBoxContainer/StarContainer.get_children()

const STAR_REVEAL_DELAY: float = 0.25
const STAR_INITIAL_SCALE: Vector2 = Vector2.ONE * 0.30
const STAR_MIDDLE_SCALE: Vector2 = Vector2.ONE * 1.20
const STAR_FINAL_SCALE: Vector2 = Vector2.ONE * 1.00
const STAR_GROW_DURATION: float = 0.15
const STAR_SETTLE_DURATION: float = 0.10
const STAR_ACTIVE_COLOR: Color = Color(1.0, 0.85, 0.1)

func _ready() -> void:
	game_over_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func update_hearts(current_lives: int) -> void:
	for i in range(heart_icons.size()):
		var heart = heart_icons[i] as TextureRect
		if i < current_lives:
			if full_heart_texture:
				heart.texture = full_heart_texture
			else:
				heart.modulate = Color.WHITE
		else:
			if empty_heart_texture:
				heart.texture = empty_heart_texture
			else:
				heart.modulate = Color(0.3, 0.3, 0.3, 0.5)

func update_timer(ratio: float) -> void:
	timer_circle.value = ratio
	timer_circle.tint_progress = Color.RED if ratio <= 0.25 else Color.WHITE

func show_victory(stars: int, time_spent: float) -> void:
	title_label.text = "Transcrição concluída!"
	var seconds = int(time_spent)
	var millis = int((time_spent - seconds) * 100)
	time_spent_label.text = "Tempo: %02d.%02ds" % [seconds, millis]
	game_over_panel.visible = true
	_animate_stars(stars)

func show_game_over(reason: String = "Fim de jogo") -> void:
	title_label.text = reason
	time_spent_label.text = ""
	game_over_panel.visible = true
	_animate_stars(0)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _animate_stars(earned_stars: int) -> void:
	for star in star_icons:
		var star_rect = star as TextureRect
		star_rect.scale = STAR_FINAL_SCALE
		if star_empty_texture:
			star_rect.texture = star_empty_texture
		else:
			star_rect.modulate = Color(0.2, 0.2, 0.2, 0.4)

	for i in range(earned_stars):
		await get_tree().create_timer(STAR_REVEAL_DELAY).timeout
		var star_rect = star_icons[i] as TextureRect

		if star_full_texture:
			star_rect.texture = star_full_texture
		else:
			star_rect.modulate = STAR_ACTIVE_COLOR
		
		star_rect.scale = STAR_INITIAL_SCALE
		var tween = create_tween()
		tween.tween_property(star_rect, "scale", STAR_MIDDLE_SCALE, STAR_GROW_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(star_rect, "scale", STAR_FINAL_SCALE, STAR_SETTLE_DURATION)
