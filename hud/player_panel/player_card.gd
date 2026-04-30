## player_card.gd
@tool
class_name PlayerCard
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var vic_points_view: AnnotatedTexture = %VictoryPoints
@onready var resources_view: AnnotatedTexture = %Resources
@onready var action_cards_view: AnnotatedTexture = %ActionCards
@onready var roads_view: AnnotatedTexture = %Roads
@onready var soldiers_view: AnnotatedTexture = %Soldiers

@export var player_id: int = 0

@export var player_name: String = "Name Not Set":
	set(value):
		name = value
		if self.is_node_ready():
			self.name_label.text = value

@export var victory_points: int = 0:
	set(value):
		victory_points = value
		if self.is_node_ready():
			self.vic_points_view.text = str(value)

@export var resources: int = 0:
	set(value):
		resources = value
		if self.is_node_ready():
			self.resources_view.text = str(value)

@export var action_cards: int = 0:
	set(value):
		action_cards = value
		if self.is_node_ready():
			self.action_cards_view.text = str(value)

@export var roads: int = 0:
	set(value):
		roads = value
		if self.is_node_ready():
			self.roads_view.text = str(value)

@export var soldiers: int = 0:
	set(value):
		soldiers = value
		if self.is_node_ready():
			self.soldiers_view.text = str(value)


func _ready() -> void:
	# Syncronize fields with view
	if self.name_label:        self.name_label.text = self.player_name
	if self.vic_points_view:   self.vic_points_view.text = str(self.victory_points)
	if self.resources_view:    self.resources_view.text = str(self.resources)
	if self.action_cards_view: self.action_cards_view.text = str(self.action_cards)
	if self.roads_view:        self.roads_view.text = str(self.roads)
	if self.soldiers_view:     self.soldiers_view.text = str(self.soldiers)

	# Attach event listeners
	EventBus.add_resources.connect(func(id: int, resources: Array) -> void:
		if id != self.player_id: return
		self.resources += resources.size()
	)

	EventBus.remove_resources.connect(func(id: int, resources: Array) -> void:
		if id != self.player_id: return
		self.resources -= resources.size()
	)

	EventBus.add_action_card.connect(func(id: int, _card: Model.ActionCards) -> void:
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

	EventBus.request_play_action_card.connect(func(id: int, card: Model.ActionCards) -> void:
		if id != self.player_id: return
		if card == Model.ActionCards.SOLDIER: self.soldiers += 1
		self.action_cards -= 1
	)

	