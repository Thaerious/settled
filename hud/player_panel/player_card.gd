## player_card.gd
@tool
class_name PlayerCard
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var portrait: TextureRect = %PortraitTexture
@onready var vic_points_view: AnnotatedTexture = %VictoryPoints
@onready var resources_view: AnnotatedTexture = %Resources
@onready var action_cards_view: AnnotatedTexture = %ActionCards
@onready var roads_view: AnnotatedTexture = %Roads
@onready var soldiers_view: AnnotatedTexture = %Soldiers

@export var player_id: int = 0

var player_name: String = "Name Not Set":
	set(value):
		name = value
		if self.is_node_ready():
			self.name_label.text = value

var victory_points: int = 0:
	set(value):
		victory_points = value
		if self.is_node_ready():
			self.vic_points_view.text = str(value)

var resources: int = 0:
	set(value):
		resources = value
		if self.is_node_ready():
			self.resources_view.text = str(value)

var action_cards: int = 0:
	set(value):
		action_cards = value
		if self.is_node_ready():
			self.action_cards_view.text = str(value)

var roads: int = 0:
	set(value):
		roads = value
		if self.is_node_ready():
			self.roads_view.text = str(value)

var soldiers: int = 0:
	set(value):
		soldiers = value
		if self.is_node_ready():
			self.soldiers_view.text = str(value)


func _ready() -> void:

	self.portrait.modulate = GameBoard.tint[self.player_id]

	# Attach event listeners
	EventBus.add_resources.connect(func(id: int, resources: Array) -> void:
		if id != self.player_id: return
		self.resources += resources.size()
	)

	EventBus.remove_resources.connect(func(id: int, resources: Array) -> void:
		if id != self.player_id: return
		self.resources -= resources.size()
	)

	EventBus.add_action_card.connect(func(id: int, _card: Model.ActionCardTypes) -> void:
		if id != self.player_id: return
		self.action_cards += 1
	)	

	EventBus.update_victory_points.connect(func(id: int, delta: int) -> void:
		if id != self.player_id: return
		self.victory_points += delta
	)	

	EventBus.set_road.connect(func(id: int, _ax: AxialEdge) -> void:
		if id != self.player_id: return
		self.roads += 1
	)	

	EventBus.request_play_action_card.connect(func(id: int, card: Model.ActionCardTypes) -> void:
		if id != self.player_id: return
		if card == Model.ActionCardTypes.SOLDIER: self.soldiers += 1
		self.action_cards -= 1
	)

	EventBus.reset_view.connect(self._reset_view)


func _reset_view() -> void:
	if (Game.self_id == self.player_id):
		self.name_label.add_theme_color_override("font_color", Color.RED)
	else:
		self.name_label.add_theme_color_override("font_color", Color.WHITE)

	var cards := Game.model.get_action_cards(self.player_id)
	var bank := Game.model.get_bank(self.player_id)
	var total_cards := 0
	for c in cards: total_cards += cards[c]

	self.player_name = Game.model.player_names[self.player_id]
	self.action_cards = total_cards
	self.soldiers = Game.model.get_army(self.player_id)
	self.roads = Game.model.get_roads(self.player_id).size()
	self.victory_points = Game.model.get_victory_points(self.player_id)

	var total_resources := 0
	for r in bank: total_resources += bank[r]
	self.resources = total_resources
