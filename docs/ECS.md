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

Eventos são objetos que são criados quando algo específico acontece. Estes então chamam métodos de sistema para determinada entidade com determinado componente.

e.g. `scripts/game/input/events/card_input_event.gd`, `scripts/game/play_cards/events/play_card_event.gd`

Padrão de nomenclatura arquivo: `snake_case_name_event.gd`

padrão de código:
```
class_name [CamelCaseNameEvent] extends [Event | SomeEvent]

# <optional>
func _init(event_args: [SomeEventArgs] = null) -> void:
	args = event_args

func treat(_entity: Entity) -> void:
    var comp : Component

    comp = EntitySystem.try_comp(entity, [SomeComponent])
    if comp != null: 
        [SomeSystem].[some_func](entity, comp, args)

    comp = EntitySystem.try_comp(entity, [SomeOtherComponent])
    if comp != null: 
        [SomeOtherSystem].[some_func](entity, comp, args)

# <optional>
class [CamelCaseNameEventArgs] extends [EventArgs | SomeEventArgs]

var [data_field] : [Type]

func _init([stuff]: [Type], ...) -> void:
	[data_field] = [stuff]
    ...
...
```

```
class_name [CamelCaseNameEventArgs] extends [EventArgs | SomeEventArgs]

var [data_field] : [Type]

func _init([stuff]: [Type], ...) -> void:
	[data_field] = [stuff]
    ...
...
```
- Todos os eventos tem que herdar de `Event` ou alguma classe que herda de `Event` 
- Todos os argumentos de evento tem que herdar de `EventArg` ou alguma classe que herda de `EventArg`
- Eventos que tem Argumentos especiais tem que ter indicado implementando _init e definindo o tipo de EventArgs
- argumentos de evento podem ser definidos em arquivos separados ou no mesmo arquivo de um evento dependendo se apenas são usados por um evento ou por vários
- Todo evento tem que implementar `func treat(entity: Entity) -> void:`
- A implementação de `treat` tem que ser da forma apresentada acima
- eventos não podem definir novos métodos ou variaveis
- argumentos de evento podem ter apenas variaveis e nenhum método

### Sistemas

Sistemas são bibliotecas de métodos estáticos que podem fazer uma variedade de coisas, incluindo alterar valores de componentes, valores de eventos, criar e iniciar eventos.

e.g. `scripts/game/input/systems/input_system.gd`, `scripts/game/play_cards/systems/play_card_system.gd`

Padrão de nomenclatura arquivo: `snake_case_name_system.gd`

padrão de código:
```
class_name [CamelCaseNameSystem] extends System

@static func [some_func]([args]) -> [Type]:
    [code]

@static func [some_func](entity: Entity, comp: [SomeComponent], event_args: [SomeEventArgs]) -> [Type]:
    [code]

...
```
- Todos os sistemas tem que herdar de `System` e apenas `System`
- Sistemas tem que ter apenas métodos estáticos
- Métodos chamados por eventos tem que ter os argumentos do tipo: `(entity: Entity, comp: [SomeComponent], event_args: [SomeEventArgs])`
- Sistemas não podem ter váriaveis