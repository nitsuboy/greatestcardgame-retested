import re

from godot_scripts_check_inheritance import checarClasseHerdaDeComponent
from godot_scripts_check_inheritance import checarClasseHerdaDeSystem
from godot_scripts_check_inheritance import checarClasseHerdaDeEvent
from godot_scripts_check_inheritance import checarClasseHerdaDeEventArgs

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def checarNomeClasseInterna(nomeClasseInterna: str, linhaNumero: int) -> int:
    numeroErros = 0
    matchRegularComponentName = re.search(r"^([A-Z][a-z0-9]*)+Component$", nomeClasseInterna)
    if matchRegularComponentName:
        print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasseInterna}{reset} segue padrão de componentes - {red}NOT OK{reset}")
        print(f"{red}classes internas não podem seguir o padrão de nomeclatura de componentes!{reset}")
        numeroErros += 1

    matchRegularSystemName = re.search(r"^([A-Z][a-z0-9]*)+System$", nomeClasseInterna)
    if matchRegularSystemName:
        print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasseInterna}{reset} segue padrão de sistemas - {red}NOT OK{reset}")
        print(f"{red}classes internas não podem seguir o padrão de nomeclatura de sistemas!{reset}")
        numeroErros += 1

    matchRegularEventName = re.search(r"^([A-Z][a-z0-9]*)+Event$", nomeClasseInterna)
    if matchRegularEventName:
        print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasseInterna}{reset} segue padrão de eventos - {red}NOT OK{reset}")
        print(f"{red}classes internas não podem seguir o padrão de nomeclatura de eventos!{reset}")
        numeroErros += 1

    matchRegularEventArgName = re.search(r"^([A-Z][a-z0-9]*)+EventArgs$", nomeClasseInterna)
    if matchRegularEventArgName:
        print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasseInterna}{reset} segue padrão de argumentos de evento - {red}NOT OK{reset}")
        print(f"{red}classes internas não podem seguir o padrão de nomeclatura de argumentos de evento!{reset}")
        numeroErros += 1

    return numeroErros

def checarHerancaClasseInterna(nomeClasseInterna: str, nomeClasseInternaPai: str, linhaNumero: int) -> int:
    numeroErros = 0
    
    if checarClasseHerdaDeComponent(nomeClasseInternaPai):
        print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClasseInternaPai}{reset} de {yellow}{nomeClasseInterna}{reset} herda de {yellow}Component{reset} - {red}NOT OK{reset}")
        print(f"{red}classes internas não devem herdar de Component!{reset}")
        numeroErros += 1

    if checarClasseHerdaDeSystem(nomeClasseInternaPai):
        print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClasseInternaPai}{reset} de {yellow}{nomeClasseInterna}{reset} herda de {yellow}System{reset} - {red}NOT OK{reset}")
        print(f"{red}classes internas não devem herdar de System!{reset}")
        numeroErros += 1

    if checarClasseHerdaDeEvent(nomeClasseInternaPai):
        print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClasseInternaPai}{reset} de {yellow}{nomeClasseInterna}{reset} herda de {yellow}Event{reset} - {red}NOT OK{reset}")
        print(f"{red}classes internas não devem herdar de Event!{reset}")
        numeroErros += 1

    if checarClasseHerdaDeEventArgs(nomeClasseInternaPai):
        print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClasseInternaPai}{reset} de {yellow}{nomeClasseInterna}{reset} herda de {yellow}EventArgs{reset} - {red}NOT OK{reset}")
        print(f"{red}classes internas não devem herdar de EventArgs!{reset}")
        numeroErros += 1

    return numeroErros
