extends Control

@onready var main_buttons: VBoxContainer = $"Main Buttons"
@onready var options: Panel = $Options


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true # Menu inicia com as opções principais visíveis
	options.visible = false # Menu inicia com as opções de config invisíveis


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void: # Realiza ação ao apertar o botão Start.
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") # !! Precisa ser adicionado o path para a cena que de início do jogo. !!


func _on_options_pressed() -> void: # Realiza ação ao apertar o botão Options.
	main_buttons.visible = false # Torna o menu inicial invisível.
	options.visible = true # Torna as opções de config visíveis.


func _on_quit_pressed() -> void: # Realiza ação ao apertar o botão Quit.
	get_tree().quit() # Fecha o jogo.


func _on_back_pressed() -> void: # Realiza ação ao apertar o botão Voltar (dentro da tela de opções).
	main_buttons.visible = true # Torna o menu inicial visível.
	options.visible = false # Torna as opções de config invisíveis.
