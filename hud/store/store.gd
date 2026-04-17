extends PanelContainer

const road_piece: Texture2D = preload("res://assets/road.png")
const city_piece: Texture2D = preload("res://assets/city.png")

@onready var road_container: Control = %RoadContainer
@onready var house_container: Control = %HouseContainer
@onready var city_container: Control = %CityContainer
@onready var card_container: Control = %CardContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("store ready")
	HouseDragHnd.new(self.house_container)