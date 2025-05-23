extends Node3D


var save_game:SaveGame = SaveGame.new()


var current_level_change = null

@onready var label_infos:Label = $UI/LabelInfos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_infos.visible = false
	GameState.player = $Player;
	save_game.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _enter_level(from_level: String, to_level: String, use_spawn_point: bool = true) -> void:
	print("enter level")
	print(from_level, to_level)
	
	if(GameState.current_level != null): GameState.current_level.queue_free()
	GameState.current_level = load("res://levels/" + to_level + ".tscn").instantiate();
	GameState.current_level_key = to_level
	add_child(GameState.current_level)
	if(use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if(spawnpoint.key == from_level):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation
	


func _on_button_quit_pressed() -> void:
	save_game.save_game()
	get_tree().quit()
	pass # Replace with function body.


func _on_player_interaction_detected(node: Node3D) -> void:
	if(node.get_parent() is LevelChange):
		label_infos.visible = true
		label_infos.text = "Appuyez sur E pour ouvrir la porte"
		current_level_change = node.get_parent()


func _on_player_interaction_released(node: Node3D) -> void:
	label_infos.visible = false
	current_level_change = null

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("player_interract") and current_level_change != null):
		_enter_level(GameState.current_level_key, current_level_change.destination_level)
		current_level_change = null
