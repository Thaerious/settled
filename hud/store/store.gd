extends PanelContainer

const road_piece: Texture2D = preload("res://assets/road.png")
const city_piece: Texture2D = preload("res://assets/city.png")

@onready var _road_container: Control = %RoadContainer
@onready var _house_container: Control = %HouseContainer
@onready var _city_container: Control = %CityContainer
@onready var _card_container: Control = %CardContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HouseDragHnd.new(self._house_container)
	CityDragHnd.new(self._city_container)
	RoadDragHnd.new(self._road_container)

	self._card_container.gui_input.connect(self._on_click_card_container)


func _on_click_card_container(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if not event.button_index == MOUSE_BUTTON_LEFT: return
	if event.pressed: return
	EventBus.request_purchase_action_card.emit()
		
	
