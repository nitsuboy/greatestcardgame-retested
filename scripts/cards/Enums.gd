enum TestType {NENHUM = -1, ESTRESSE, USABILIDADE, SEGURANCA, DESEMPENHO, FUNCIONALIDADE, ACEITACAO}  # Para cartas que não são de teste  # t,estresse  # t,usabilidade  # t,segurança  # t,desempenho  # t,funcionalidade  # t,aceitação

enum EffectsType { CARD, PLAYER }

enum CardType { ACTION, QUESTION, ANSWER }

enum TurnState { START, DRAW, MAIN, RESOLVE, END }
