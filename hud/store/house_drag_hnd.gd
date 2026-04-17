class_name HouseDragHnd
extends ProductBase

const HOUSE_TEXTURE: Texture2D = preload("res://assets/house.png")
const HOUSE_PIECE: PackedScene = preload("res://game_board/house_piece.tscn")
const ICON_SIZE = Vector2(64,64)

var trigger: Control
var _house_piece = HOUSE_PIECE.instantiate()
var _last_target: TargetPiece = null


func _init(trigger: Control) -> void:
	self.trigger = trigger
	self.trigger.gui_input.connect(self._house_press)


func _house_press(event: InputEvent) -> void:
	if is_left_click(event): self._start_drag()


func _start_drag() -> void:
	print("_start_drag")
	self._house_piece = HOUSE_PIECE.instantiate()

	var args = DragArgs.new()
	args.texture = HOUSE_TEXTURE
	args.payload = "house"
	args.size    = ICON_SIZE
	args.offset  = Vector2.ZERO	
	args.on_success = self._on_success
	args.on_failure = self._on_failure
	args.on_enter = self._on_enter
	args.on_exit = self._on_exit

	EventBus.show_house_targets.emit()
	MouseBus.start_drag(args)

func _on_success(_rec: DragRecord) -> void:
	print("_on_success ", self._last_target)
	EventBus.clear_targets.emit()
	if self._last_target: EventBus.set_house.emit(_last_target.position)
	self._last_target = null


func _on_failure(_rec: DragRecord) -> void:
	print("_on_failure ", self._last_target)
	EventBus.clear_targets.emit()
	self._last_target = null


func _on_enter(rec: HoverRecord) -> void:	
	if not rec.entered.owner is TargetPiece: return		

	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.entered.owner as TargetPiece
	self._last_target.set_piece(self._house_piece)
	print("_on_enter ", self._last_target)
	

func _on_exit(rec: HoverRecord) -> void:	
	if not rec.exited.owner is TargetPiece: return	
	if not self._last_target: return

	print("_on_exit")
	self._last_target.clear_piece()
	self._last_target = null
