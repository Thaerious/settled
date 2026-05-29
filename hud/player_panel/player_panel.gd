extends Control

@onready var player_0_portrait_style = load("res://hud/player_panel/player_0_portrait_style.tres")
@onready var player_0_name_style = load("res://hud/player_panel/player_0_name_style.tres")
@onready var player_1_portrait_style = load("res://hud/player_panel/player_1_portrait_style.tres")
@onready var player_1_name_style = load("res://hud/player_panel/player_1_name_style.tres")
@onready var player_2_portrait_style = load("res://hud/player_panel/player_2_portrait_style.tres")
@onready var player_2_name_style = load("res://hud/player_panel/player_2_name_style.tres")
@onready var player_3_portrait_style = load("res://hud/player_panel/player_3_portrait_style.tres")
@onready var player_3_name_style = load("res://hud/player_panel/player_3_name_style.tres")


@export var player_id: int = 0


var player_record: PlayerRecord = null:
	set(value):
		player_record = value
		if self.is_node_ready():
			self._update_style()


func _ready() -> void:
	EventBus.model_loaded.connect(func():
		self.player_record = Game.model.get_player_record(Game.self_id)
	)

	%PortraitTexture.texture = self.get_random_texture("res://assets/portraits/")


func _update_style() -> void:
	match self.player_id:
		0: 
			%PortraitPanel.add_theme_stylebox_override("panel", self.player_0_portrait_style)
			%NamePanel.add_theme_stylebox_override("panel", self.player_0_name_style)
		1: 
			%PortraitPanel.add_theme_stylebox_override("panel", self.player_1_portrait_style)
			%NamePanel.add_theme_stylebox_override("panel", self.player_1_name_style)
		2: 
			%PortraitPanel.add_theme_stylebox_override("panel", self.player_2_portrait_style)
			%NamePanel.add_theme_stylebox_override("panel", self.player_2_name_style)
		3: 
			%PortraitPanel.add_theme_stylebox_override("panel", self.player_3_portrait_style)
			%NamePanel.add_theme_stylebox_override("panel", self.player_3_name_style)


func get_random_texture(dir_path: String) -> Texture2D:
	var files = DirAccess.get_files_at(dir_path)
	var textures = PackedStringArray()
	for f in files:
		if f.ends_with(".png") or f.ends_with(".jpg"):
			textures.append(f)
	if textures.is_empty():
		return null
	var file = textures[randi() % textures.size()]
	return load(dir_path + "/" + file)