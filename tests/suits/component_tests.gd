# GdUnit generated TestSuite
class_name ComponentTests
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source = "res://addons/truco/core/ecs/component.gd"

func test_should_serialize_defaults_true() -> void:
	var comp = Component.new()
	assert(comp.should_serialize())

func test_to_dict_returns_empty_for_base_component() -> void:
	var comp = Component.new()
	var dict = comp.to_dict()
	assert(dict.is_empty())

func test_to_dict_includes_exported_properties() -> void:
	var comp = DummyComponentWithData.new()
	var dict = comp.to_dict()
	assert(dict.has("int_val"))
	assert(dict.has("float_val"))
	assert(dict.has("string_val"))
	assert(dict.has("bool_val"))
	assert(dict.has("vector_val"))

func test_to_dict_excludes_private_properties() -> void:
	var comp = DummyComponentWithData.new()
	var dict = comp.to_dict()
	assert(!dict.has("_private_val"))

func test_to_dict_excludes_resource_meta_properties() -> void:
	var comp = DummyComponentWithData.new()
	var dict = comp.to_dict()
	assert(!dict.has("script"))
	assert(!dict.has("resource_path"))
	assert(!dict.has("resource_name"))

func test_to_dict_serializes_int() -> void:
	var comp = DummyComponentWithData.new()
	comp.int_val = 99
	assert(comp.to_dict()["int_val"] == 99)

func test_to_dict_serializes_float() -> void:
	var comp = DummyComponentWithData.new()
	comp.float_val = 2.718
	assert(comp.to_dict()["float_val"] == 2.718)

func test_to_dict_serializes_string() -> void:
	var comp = DummyComponentWithData.new()
	comp.string_val = "test"
	assert(comp.to_dict()["string_val"] == "test")

func test_to_dict_serializes_bool() -> void:
	var comp = DummyComponentWithData.new()
	comp.bool_val = false
	assert(comp.to_dict()["bool_val"] == false)

func test_to_dict_serializes_vector2_as_dict() -> void:
	var comp = DummyComponentWithData.new()
	comp.vector_val = Vector2(5, 15)
	var dict = comp.to_dict()
	assert(dict["vector_val"] is Dictionary)
	assert(dict["vector_val"]["x"] == 5)
	assert(dict["vector_val"]["y"] == 15)

func test_from_dict_restores_int() -> void:
	var comp = DummyComponentWithData.new()
	comp.from_dict({"int_val": 77})
	assert(comp.int_val == 77)

func test_from_dict_restores_float() -> void:
	var comp = DummyComponentWithData.new()
	comp.from_dict({"float_val": 1.618})
	assert(comp.float_val == 1.618)

func test_from_dict_restores_string() -> void:
	var comp = DummyComponentWithData.new()
	comp.from_dict({"string_val": "world"})
	assert(comp.string_val == "world")

func test_from_dict_restores_bool() -> void:
	var comp = DummyComponentWithData.new()
	comp.from_dict({"bool_val": false})
	assert(comp.bool_val == false)

func test_from_dict_restores_vector2() -> void:
	var comp = DummyComponentWithData.new()
	comp.from_dict({"vector_val": {"x": 30, "y": 40}})
	assert(comp.vector_val == Vector2(30, 40))

func test_from_dict_roundtrip() -> void:
	var comp = DummyComponentWithData.new()
	comp.int_val = 100
	comp.float_val = 2.5
	comp.string_val = "round"
	comp.bool_val = false
	comp.vector_val = Vector2(1, 2)
	var dict = comp.to_dict()
	var comp2 = DummyComponentWithData.new()
	comp2.from_dict(dict)
	assert(comp2.int_val == 100)
	assert(comp2.float_val == 2.5)
	assert(comp2.string_val == "round")
	assert(comp2.bool_val == false)
	assert(comp2.vector_val == Vector2(1, 2))
