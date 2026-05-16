class_name DebugSidebar
extends Panel

@export var wlr: WorldRunner

var signals

var _start_time: int
var _event_times: Dictionary = {}  # nome → timestamp string
var _event_data: Dictionary = {}  # nome → último valor string

@onready var list: VBoxContainer = $ScrollContainer/VBoxContainer


func _ready() -> void:
	await get_tree().process_frame
	signals = wlr.world.events.get_signal_list()
	_start_time = Time.get_ticks_msec()
	_build_ui()
	connect_to(wlr.world)


func _build_ui() -> void:
	for event in signals:
		var hbox = HBoxContainer.new()
		hbox.name = event["name"]
		var label = Label.new()
		label.text = event["name"]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var time_label = Label.new()
		time_label.name = "time"
		time_label.text = "—"
		var data_label = Label.new()
		data_label.name = "data"
		data_label.text = ""
		hbox.add_child(label)
		hbox.add_child(time_label)
		hbox.add_child(data_label)
		list.add_child(hbox)


func _log(name: String, data: String = "") -> void:
	var elapsed = Time.get_ticks_msec() - _start_time
	var t = "%03d.%03d" % [elapsed / 1000, elapsed % 1000]
	var tlabel = list.get_node(name + "/time") as Label
	var dlabel = list.get_node(name + "/data") as Label
	if tlabel:
		tlabel.text = t
	if dlabel:
		dlabel.text = data


func connect_to(world: World) -> void:
	var eb = world.events
	for sig in signals:
		eb.connect(sig["name"], func(...varargs): _log("%s" % sig["name"], "args=%s" % [varargs]))


func _clear() -> void:
	_event_times.clear()
	_event_data.clear()
	for event in signals:
		var tlabel = list.get_node(event + "/time") as Label
		var dlabel = list.get_node(event + "/data") as Label
		if tlabel:
			tlabel.text = "—"
		if dlabel:
			dlabel.text = ""
