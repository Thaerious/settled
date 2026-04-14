## drag_record.gd
class_name DragRecord

enum DropResult {
    MISSED     = 0,
    ON_DROP    = 1,
    NO_HANDLER = 2,
}

var draggable:       Node
var destination:     Variant
var payload:         Variant
var local_position:  Vector2
var world_position:  Vector2
var screen_position: Vector2
var succeeded:       DropResult = DropResult.MISSED

func _init(
	draggable:       Node,	
	payload:         Variant,
	screen_position: Vector2,
	world_position:  Vector2,
) -> void:
	self.draggable       = draggable
	self.payload         = payload
	self.screen_position = screen_position
	self.world_position  = world_position
	# local_position and destination are set later by MouseBus once a drop target is known
