extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") # !! Precisa ser adicionado o path para a cena que de início do jogo. !!


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn") # Muda para a cena de opções quando o botão Options é pressionado.


func _on_quit_pressed() -> void:
	get_tree().quit() # Fecha o jogo ao apertar o botão Quit.
