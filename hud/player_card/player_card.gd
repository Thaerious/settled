extends Control

@onready var name_label: Label = %NameLabel
@onready var outer_box: Control = %OuterHBox

@onready var vic_points_texture: TextureRect = %VictoryIcon
@onready var resources_texture: TextureRect = %ResourcesIcon
@onready var action_cards_texture: TextureRect = %ActionIcon
@onready var roads_texture: TextureRect = %RoadsIcon
@onready var soldiers_texture: TextureRect = %SoldierIcon

@onready var vic_points_label: Label = %VictoryLabel
@onready var resources_label: Label = %ResourcesLabel
@onready var action_cards_label: Label = %ActionLabel
@onready var roads_label: Label = %RoadsLabel
@onready var soldiers_label: Label = %SoldierLabel

@onready var player_0_portrait_style = preload("res://hud/player_card/player_0_portrait_style.tres")
@onready var player_0_name_style = preload("res://hud/player_card/player_0_name_style.tres")
@onready var player_1_portrait_style = preload("res://hud/player_card/player_1_portrait_style.tres")
@onready var player_1_name_style = preload("res://hud/player_card/player_1_name_style.tres")
@onready var player_2_portrait_style = preload("res://hud/player_card/player_2_portrait_style.tres")
@onready var player_2_name_style = preload("res://hud/player_card/player_2_name_style.tres")
@onready var player_3_portrait_style = preload("res://hud/player_card/player_3_portrait_style.tres")
@onready var player_3_name_style = preload("res://hud/player_card/player_3_name_style.tres")

@export var player_id: int = 0

var x_pos_shift: float = 40

var player_record: PlayerRecord = null:
	set(value):
		player_record = value
		if self.is_node_ready():
			self._update_style()
			self._update_values()


func _ready() -> void:
	EventBus.model_loaded.connect(func():
		self.player_record = Game.model.get_player_record(self.player_id)
		self._update_position(Game.model.get_current_player())
	)

	EventBus.player_record_updated.connect(func(id: int, rec: PlayerRecord):
		if self.player_id == id:
			self.player_record = rec
	)

	EventBus.current_player_updated.connect(self._update_position)

	%PortraitTexture.texture = self.get_random_texture("res://assets/portraits/")
	await get_tree().process_frame
	

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


func _update_values() -> void:
	self.name_label.text           = self.player_record.name
	self.vic_points_label.text     = str(self.player_record.victory_points)
	self.resources_label.text      = str(self.player_record.resources)
	self.action_cards_label.text   = str(self.player_record.action_cards)
	self.roads_label.text          = str(self.player_record.roads)
	self.soldiers_label.text       = str(self.player_record.soldiers)


func _update_position(current_player_id: int) -> void:
	if self.player_id == current_player_id:
		self.outer_box.position.x = self.x_pos_shift
	else:
		self.outer_box.position.x = 0


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
