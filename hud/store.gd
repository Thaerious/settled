extends PanelContainer

signal show_house_targets()
signal show_city_targets()
signal show_road_targets()

const road_piece: Texture2D = preload("res://assets/road.png")
const house_piece: Texture2D = preload("res://assets/house.png")
const city_piece: Texture2D = preload("res://assets/city.png")

@onready var road_container: Control = %RoadContainer
@onready var house_container: Control = %HouseContainer
@onready var city_container: Control = %CityContainer
@onready var card_container: Control = %CardContainer

const ICON_SIZE = Vector2(64,64)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.road_container.gui_input.connect(self._road_press)
	self.house_container.gui_input.connect(self._house_press)
	self.city_container.gui_input.connect(self._city_press)
	self.card_container.gui_input.connect(self._card_press)

static func is_left_click(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and event.pressed
	)

func _on_success(record: DragRecord) -> void:
	pass


func _on_reject(record: DragRecord) -> void:
	pass


func _road_press(event: InputEvent) -> void:
	if is_left_click(event):
		self.show_road_targets.emit()
		MouseBus.start_drag(road_piece, "house", ICON_SIZE, Vector2.ZERO, self._on_success, self._on_reject)


func _house_press(event: InputEvent) -> void:
	if is_left_click(event):
		self.show_house_targets.emit()
		MouseBus.start_drag(house_piece, "house", ICON_SIZE, Vector2.ZERO, self._on_success, self._on_reject)


func _city_press(event: InputEvent) -> void:
	if is_left_click(event):
		self.show_city_targets.emit()
		MouseBus.start_drag(city_piece, "house", ICON_SIZE, Vector2.ZERO, self._on_success, self._on_reject)


func _card_press(event: InputEvent) -> void:
	if is_left_click(event):
		pass				