extends Node

@onready var dice := RandomNumberGenerator.new()

func _ready() -> void:
	TestChallengeSystem()

func TestChallengeSystem() -> void:
	print("Running Challenge Test")

	# Step 1: Create a Desafio card manually
	var desafio := DesafioCardData.new()
	desafio.description = "Fake card for testing"
	desafio.test_requirements = {
		"test 1": [],
		"test 2": [4, 5],
		"test 3": [],
		"test 4": [1, 2, 3]
	}

	# Step 2: Pick a test to attempt
	var chosen_test := "test 4"
	print("Chosen test:", chosen_test)

	# Step 3: Simulate a dice roll (1-6)
	dice.randomize()
	var roll := dice.randi_range(1, 6)
	print("Dice roll result:", roll)

	# Step 4: Check success
	if ChallengeEvaluator.IsSuccessfulRoll(chosen_test, desafio, roll):
		print("✅ Success! Test passed, +1 point.")
	else:
		print("❌ Failed! No points.")
