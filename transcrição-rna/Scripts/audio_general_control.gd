extends HSlider


var audio_bus_id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name) # Pega o ID da faixa de áudio.


@export var audio_bus_name: String


func _on_value_changed(value: float) -> void: # Faz uma ação proporcional ao quanto muda na barra de rolamento.
	var db = linear_to_db(value) # Corrige a curva de sensação do som.
	AudioServer.set_bus_volume_db(audio_bus_id, db) # Define o volume.
