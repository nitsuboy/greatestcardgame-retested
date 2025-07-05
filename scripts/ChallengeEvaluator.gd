# ChallengeEvaluator.gd
extends Node
class_name ChallengeEvaluator

static func IsValidTest(test_name: String, desafio_card: CardData) -> bool:
	return desafio_card.test_data.has(test_name)

static func IsSuccessfulRoll(test_name: String, desafio_card: CardData, roll: int) -> bool:
	if not desafio_card.test_data.has(test_name):
		return false
	var valid_numbers: Array[int] = desafio_card.test_data[test_name]
	return valid_numbers.has(roll)
