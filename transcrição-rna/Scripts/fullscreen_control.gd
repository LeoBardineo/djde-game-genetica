extends CheckButton


func _on_toggled(toggled_on: bool) -> void: # Realiza ação ao ativar o switch.
	if toggled_on == true: # Se ativo...
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) # Ativa o modo fullscreen.
	else: # Caso contrário...
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) # Ativa o modo janela.
