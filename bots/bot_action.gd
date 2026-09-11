class_name BotAction
extends RefCounted


static var INT_MAX:int = 9223372036854775807
static var END := BotAction.new("end", -INT_MAX, null)
static var ROLL := BotAction.new("roll", INT_MAX, null)
static var NOOP := BotAction.new("no-op", -INT_MAX, null)
static var WAIT := BotAction.new("wait", INT_MAX, null)


var action := "no-op"
var rank:int = -INT_MAX
var data:Variant = null


func _init(action: String = "no-op", rank: int = -INT_MAX, data: Variant = null):
	self.action = action
	self.rank = rank
	self.data = data

func _to_string() -> String:
	var s_rank: String = str(rank)
	if self.rank == INT_MAX: s_rank = "∞"
	elif self.rank == -INT_MAX: s_rank = "-∞"

	if data == null:
		return "[action: %s | rank: %s]" % [self.action, s_rank]
	else:
		return "[action: %s | rank: %s | data: %s]" % [self.action, s_rank, self.data]