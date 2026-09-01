extends CanvasLayer
class_name HUD

@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D

@onready var heart_icons: Array = $HeartsContainer.get_children()
@onready var game_over_panel: Panel = $GameOverPanel
@onready var restart_button: Button = $GameOverPanel/RestartButton

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

func show_game_over() -> void:
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
