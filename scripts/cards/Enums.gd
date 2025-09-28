enum TestType {
	NENHUM = -1,         # Para cartas que não são de teste
	ESTRESSE,            # t,estresse
	USABILIDADE,         # t,usabilidade
	SEGURANCA,           # t,segurança
	DESEMPENHO,          # t,desempenho
	FUNCIONALIDADE,      # t,funcionalidade
	ACEITACAO            # t,aceitação
}

enum EffectsType {
	CARD,
	PLAYER
}

enum CardType {
	ACTION,
	QUESTION,
	ANSWER
}

enum TurnState { 
	START, 
	DRAW, 
	MAIN, 
	RESOLVE, 
	END 
}
