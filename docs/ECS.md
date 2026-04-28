# Modelo ECS de código

### Módulos

Módulos são pastas dentro de `scripts/game/` que contêm códigos ECS relacionados com algum aspecto.

e.g. `scripts/game/input`, `scripts/game/ecs`, `scripts/game/card`

Padrão de nomenclatura pasta: `snake_case_name`

Estrutura interna de um módulo:
```
<pasta_modulo>
├── components/
├── events/
└── systems/
```
- Componentes e Eventos são opcionais para um módulo
- Todo módulo tem que ter pelo menos um sistema

### Componentes

Componentes são objetos presentes em entidades e dão características e comportamentos para essa entidade através de sistemas

e.g. `scripts/game/dragging/components/draggable_component.gd`, `scripts/game/zoom/components/zoomable_component.gd`

Padrão de nomenclatura arquivo: `snake_case_name_component.gd`

Padrão de código:
```
class_name [CamelCaseNameComponent] extends Component

var [data_field] : [Type]
...
```
- Todos os componentes têm que herdar de `Component`, ou de outro componente
- O Componente não pode ter nenhum método, apenas variáveis

### Eventos

Eventos são objetos que são criados quando algo específico acontece. Ao iniciar um evento, determinados metódos são chamados para entidades com determinados componentes

e.g. `scripts/game/input/events/card_input_event.gd`, `scripts/game/play_cards/events/play_card_event.gd`

Padrão de nomenclatura arquivo: `snake_case_name_event.gd`

padrão de código:
```
class_name [CamelCaseNameEvent] extends [Event | SomeEvent]

var [data_field] : [Type]

func _init([stuff]: [Type], ...) -> void:
	[data_field] = [stuff]
    ...
```
- Todos os eventos tem que herdar de `Event` ou alguma classe que herda de `Event` 
- Eventos podem ter apenas variaveis e nenhum método além de _init

### Sistemas

Sistemas são bibliotecas de métodos estáticos que podem fazer uma variedade de coisas, incluindo alterar valores de componentes, valores de eventos, criar e iniciar eventos.

e.g. `scripts/game/input/systems/input_system.gd`, `scripts/game/play_cards/systems/play_card_system.gd`

Padrão de nomenclatura arquivo: `snake_case_name_system.gd`

padrão de código:
```
class_name [CamelCaseNameSystem] extends System

static func initialize():
    EventSystem.inscrever_evento_local(
		[SomeComponent], [SomeEvent], Callable([SystemName], "on_[something]")
	)
    ...

static func on_[some_func](_entity: Entity, _comp: [SomeComponent], _args: [SomeEvent]) -> void:
    [code]

static func [some_func]([args]) -> [Type]:
    [code]

...
```
- Todos os sistemas tem que herdar de `System` e apenas `System`
- Sistemas tem que ter apenas métodos estáticos
- Métodos chamados por eventos locais (aqueles dentro de inscrever_evento_local) tem que ter os argumentos do tipo: `(_entity: Entity, _comp: [SomeComponent], _args: [SomeEvent])` e devem seguir o padrão `on_[something]`
- Métodos chamados por eventos globais (aqueles dentro de inscrever_evento_global) tem que ter os argumentos do tipo: `(_args: [SomeEvent])` e devem seguir o padrão `on_[something]`
- Sistemas não podem ter váriaveis
