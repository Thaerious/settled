## player_card.gd
class_name PlayerCard
extends PanelContainer

@export var player_id: int = 0

@onready var name_view: Label = %NameLabel
@onready var portrait: TextureRect = %PortraitTexture
@onready var vic_points_view: AnnotatedTexture = %VictoryPoints
@onready var resources_view: AnnotatedTexture = %Resources
@onready var action_cards_view: AnnotatedTexture = %ActionCards
@onready var roads_view: AnnotatedTexture = %Roads
@onready var soldiers_view: AnnotatedTexture = %Soldiers

func _ready() -> void:
	self.portrait.modulate = GameBoard.tint[self.player_id]

	EventBus.player_record_updated.connect(func(id: int, record: PlayerRecord) -> void:
		if id != self.player_id: return
		self.name_view.text           = record.name
		self.vic_points_view.text     = str(record.victory_points)
		self.resources_view.text      = str(record.resources)
		self.action_cards_view.text   = str(record.action_cards)
		self.roads_view.text          = str(record.roads)
		self.soldiers_view.text       = str(record.soldiers)
	)

	EventBus.update_longest_road.connect(func(id: int) -> void:
		self.roads_view.modulate = Color.WHITE
		if id == self.player_id: self.roads_view.modulate = Color.YELLOW
	)

	EventBus.update_largest_army.connect(func(id: int) -> void:
		self.soldiers_view.modulate = Color.WHITE
		if id == self.player_id: self.soldiers_view.modulate = Color.YELLOW
	)

	EventBus.model_loaded.connect(self._model_loaded)


func _model_loaded() -> void:
	var record = Game.model.get_player_record(self.player_id)
	self.name_view.text           = record.name
	self.vic_points_view.text     = str(record.victory_points)
	self.resources_view.text      = str(record.resources)
	self.action_cards_view.text   = str(record.action_cards)
	self.roads_view.text          = str(record.roads)
	self.soldiers_view.text       = str(record.soldiers)

	if Game.self_id == self.player_id:
		self.name_view.add_theme_color_override("font_color", Color.RED)
	else:
		self.name_view.add_theme_color_override("font_color", Color.WHITE)

	if Game.model.get_longest_road() == self.player_id:
		self.roads_view.modulate = Color.YELLOW

	if Game.model.get_largest_army() == self.player_id:
		self.soldiers_view.modulate = Color.YELLOW
