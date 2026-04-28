from pathlib import Path
import sys
import re

from godot_scripts_check_inheritance import checarClasseHerdaDeEvent
from godot_scripts_check_inheritance import checarClasseHerdaDeComponent
from godot_scripts_check_inheritance import checarClasseHerdaDeSystem
from ecs_check_internal_class import checarNomeClasseInterna
from ecs_check_internal_class import checarHerancaClasseInterna

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts/game")
    numeroErros = 0
    numeroSistemasChecados = 0

    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_system.gd"):
            numeroErros += checarSistema(arquivo)
            numeroSistemasChecados += 1

    print(f"{numeroSistemasChecados} sistemas checados. número de problemas: {green if numeroErros == 0 else red}{numeroErros}{reset}")
    sys.exit(numeroErros)

def checarSistema(arquivo: Path) -> int:
    numeroErros = 0

    linhas = arquivo.read_text().split("\n")

    nomeClasse = None
    nomeClasseInterna = None

    funcoes_local_on: list[str] = []
    funcoes_global_on: list[str] = []

    nomeArquivo = arquivo.name.removesuffix("_system.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "System"

    dentroFuncao = False

    for index, linha in enumerate(linhas):
        linhaNumero = index + 1

        # matches the line: class_name [Something]
        matchClassName = re.search(r"class_name\s+(\w+)", linha)
        if matchClassName:
            nomeClasse = matchClassName.group(1)

            if nomeClasse != nomeClassePadrao:
                print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasse}{reset} diferente do padrão: {yellow}{nomeClassePadrao}{reset} - {red}NOT OK{reset}")
                print(f"{red}o nome da classe deve seguir o padrão do nome do arquivo!{reset}")
                numeroErros += 1

        # matches the line: class [Something]
        matchClass = re.search(r"class\s+(\w+)", linha)
        if matchClass:
            nomeClasseInterna = matchClass.group(1)
            numeroErros += checarNomeClasseInterna(nomeClasseInterna, linhaNumero)

        # matches the line: extends [Something]
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if not nomeClasseInterna and not checarClasseHerdaDeSystem(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}System{reset} - {red}NOT OK{reset}")
                print(f"{red}todos os sistemas devem herdar diretamente de System!{reset}")
                numeroErros += 1
            elif nomeClasseInterna:
                numeroErros += checarHerancaClasseInterna(nomeClasseInterna, nomeClassePai, linhaNumero)

        # matches the line: EventSystem.InscreverEventoLocal([something], [something], Callable([something], "[someting]"))
        matchInscreverEventoLocal = re.search(r"EventSystem\.InscreverEventoLocal\s*\(\s*(\w+),\s*(\w+),\s*Callable\s*\((\w+),\s*\"(\w+)\"\s*\)\s*\)", linha)
        if matchInscreverEventoLocal:
            componente = matchInscreverEventoLocal.group(1)
            evento = matchInscreverEventoLocal.group(2)
            sistema = matchInscreverEventoLocal.group(3)
            funcao_on = matchInscreverEventoLocal.group(4)

            if not checarClasseHerdaDeComponent(componente):
                print(f"linha {linhaNumero}: primeiro argumento {yellow}{componente}{reset} de InscreverEventoLocal não é um componente - {red}NOT OK{reset}")
                print(f"{red}o primeiro argumento de InscreverEventoLocal deve ser um componente!{reset}")
                numeroErros += 1
            
            if not checarClasseHerdaDeEvent(evento):
                print(f"linha {linhaNumero}: segundo argumento {yellow}{evento}{reset} de InscreverEventoLocal não é um evento - {red}NOT OK{reset}")
                print(f"{red}o segundo argumento de InscreverEventoLocal deve ser um evento!{reset}")
                numeroErros += 1
            
            if sistema != nomeClasse:
                print(f"linha {linhaNumero}: classe do Callable {yellow}{sistema}{reset} não é o sistema atual - {red}NOT OK{reset}")
                print(f"{red}inscrições de eventos locais devem usar o sistema na qual estão sendo declaradas{reset}")
                numeroErros += 1

            matchOnMethod = re.search(r"on_(\w+)", funcao_on)
            if not matchOnMethod:
                print(f"linha {linhaNumero}: função do Callable {yellow}{funcao_on}{reset} não segue padrão de nome - {red}NOT OK{reset}")
                print(f"{red}funções inscritas em eventos locais devem começar com \"on_\"{reset}")
                numeroErros += 1
            else:
                funcoes_local_on.append(funcao_on)
        
        # matches the line: EventSystem.InscreverEventoGlobal([something], [something], Callable([something], "[someting]"))
        matchInscreverEventoGlobal = re.search(r"EventSystem\.InscreverEventoGlobal\s*\(\s*(\w+),\s*Callable\s*\((\w+),\s*\"(\w+)\"\s*\)\s*\)", linha)
        if matchInscreverEventoGlobal:
            evento = matchInscreverEventoGlobal.group(1)
            sistema = matchInscreverEventoGlobal.group(2)
            funcao_on = matchInscreverEventoGlobal.group(3)
            
            if not checarClasseHerdaDeEvent(evento):
                print(f"linha {linhaNumero}: primeiro argumento {yellow}{evento}{reset} de InscreverEventoLocal não é um evento - {red}NOT OK{reset}")
                print(f"{red}o segundo argumento de InscreverEventoGlobal deve ser um evento!{reset}")
                numeroErros += 1
            
            if sistema != nomeClasse:
                print(f"linha {linhaNumero}: classe do Callable {yellow}{sistema}{reset} não é o sistema atual - {red}NOT OK{reset}")
                print(f"{red}inscrições de eventos locais devem usar o sistema na qual estão sendo declaradas{reset}")
                numeroErros += 1

            matchOnMethod = re.search(r"on_(\w+)", funcao_on)
            if not matchOnMethod:
                print(f"linha {linhaNumero}: função do Callable {yellow}{funcao_on}{reset} não segue padrão de nome - {red}NOT OK{reset}")
                print(f"{red}funções inscritas em eventos locais devem começar com \"on_\"{reset}")
                numeroErros += 1
            else:
                funcoes_global_on.append(funcao_on)
            
        # matches the line: static func [Something]
        matchStaticFunc = re.search(r"(static)?\s*func\s+(\w+)", linha)
        if matchStaticFunc:
            static = matchStaticFunc.group(1)
            nomeFuncao = matchStaticFunc.group(2)

            dentroFuncao = True

            if not static and not nomeClasseInterna:
                print(f"linha {linhaNumero}: função {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} não é estática - {red}NOT OK{reset}")
                print(f"{red}todas as funções de sistemas devem ser estáticas!{reset}")
                numeroErros += 1
            elif nomeClasseInterna and nomeFuncao != "_init":
                print(f"linha {linhaNumero}: função {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseInterna}{reset} - {red}NOT OK{reset}")
                print(f"{red}classes internas só podem ter a função _init!{reset}")
                numeroErros += 1
            elif nomeFuncao in funcoes_local_on:
                numeroErros += checarFuncaoEventoLocal(linha, nomeFuncao)
            elif nomeFuncao in funcoes_global_on:
                numeroErros += checarFuncaoEventoGlobal(linha, nomeFuncao)

        # matches the line: var [Something]
        matchVar = re.search(r"(\t+)?var\s+(\w+)", linha)
        if matchVar:
            tabs = matchVar.group(1)
            nomeVar = matchVar.group(2)

            if (not tabs or not dentroFuncao) and not nomeClasseInterna:
                print(f"linha {linhaNumero}: variável {yellow}{nomeVar}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
                print(f"{red}sistemas não podem ter variáveis!{reset}")
                numeroErros += 1

    if not nomeClasse:
        print(f"não encontrado linha com {yellow}class_name {nomeClassePadrao}{reset} - {red}NOT OK{reset}")
        print(f"{red}arquivos de sistema devem declarar a classe daquele sistema!{reset}")
        numeroErros += 1

    print(f"arquivo sistema: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

def checarFuncaoEventoLocal(linha: str, nomeFuncao: str) -> int:
    numeroErros = 0

    # matches the line: static func [Something]([something]: [something], [something]: [something], [something]: [something]) -> void:
    matchFunc = re.search(r"(static)?\s*func\s+(\w+)\s*\(\s*(\w+)(\s*:\s*(\w+))?\s*,\s*(\w+)(\s*:\s*(\w+))?\s*,\s*(\w+)(\s*:\s*(\w+))?\s*\)(\s*->\s*(\w+))?\s*:", linha)
    if not matchFunc:
        print(f"função {yellow}{nomeFuncao}{reset} inscrita em um evento local não segue padrão - {red}NOT OK{reset}")
        print(f"{red}funções inscritas em eventos locais devem ter o padrão: \"static func [nomeFunção](_entity: Entity, _comp: [SomeComponent], _args: [SomeEvent]) -> void:\"{reset}")
        numeroErros += 1
        return numeroErros
    
    static = matchFunc.group(1)
    _entity = matchFunc.group(3)
    type_1 = matchFunc.group(4)
    Entity = matchFunc.group(5)
    _comp = matchFunc.group(6)
    type_2 = matchFunc.group(7)
    SomeComponent = matchFunc.group(8)
    _args = matchFunc.group(9)
    type_3 = matchFunc.group(10)
    SomeEvent = matchFunc.group(11)
    saida = matchFunc.group(12)
    void = matchFunc.group(13)

    if not static:
        print(f"função {yellow}{nomeFuncao}{reset} não é estática - {red}NOT OK{reset}")
        print(f"{red}todas as funções de sistemas devem ser estáticas!{reset}")
        numeroErros += 1

    if _entity != "_entity":
        print(f"primeiro argumento {yellow}{_entity}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"_entity\" - {red}NOT OK{reset}")
        print(f"{red}o primeiro argumento de funções inscritas em eventos locais deve ser \"_entity\"{reset}")
        numeroErros += 1
    
    if not type_1:
        print(f"primeiro argumento {yellow}{_entity}{reset} da função {yellow}{nomeFuncao}{reset} precisa de um tipo declarado - {red}NOT OK{reset}")
        print(f"{red}o primeiro argumento de funções inscritas em eventos locais deve ter o tipo declarado{reset}")
        numeroErros += 1
    else:
        if Entity != "Entity":
            print(f"o tipo do primeiro argumento {yellow}{_entity}{reset} da função {yellow}{nomeFuncao}{reset}, {yellow}{Entity}{reset} deve ser \"Entity\" - {red}NOT OK{reset}")
            print(f"{red}o primeiro argumento de funções inscritas em eventos locais deve ser do tipo \"Entity\"{reset}")
            numeroErros += 1
    
    if _comp != "_comp":
        print(f"segundo argumento {yellow}{_comp}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"_comp\" - {red}NOT OK{reset}")
        print(f"{red}o segundo argumento de funções inscritas em eventos locais deve ser \"_comp\"{reset}")
        numeroErros += 1
    
    if not type_2:
        print(f"segundo argumento {yellow}{_comp}{reset} da função {yellow}{nomeFuncao}{reset} precisa de um tipo declarado - {red}NOT OK{reset}")
        print(f"{red}o segundo argumento de funções inscritas em eventos locais deve ter o tipo declarado{reset}")
        numeroErros += 1
    else:
        if not checarClasseHerdaDeComponent(SomeComponent):
            print(f"o tipo do segundo argumento {yellow}{_comp}{reset} da função {yellow}{nomeFuncao}{reset}, {yellow}{SomeComponent}{reset} deve ser um componente - {red}NOT OK{reset}")
            print(f"{red}o segundo argumento de funções inscritas em eventos locais deve ser um componente{reset}")
            numeroErros += 1
    
    if _args != "_args":
        print(f"terceiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"_args\" - {red}NOT OK{reset}")
        print(f"{red}o terceiro argumento de funções inscritas em eventos locais deve ser \"_args\"{reset}")
        numeroErros += 1
    
    if not type_3:
        print(f"terceiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset} precisa de um tipo declarado - {red}NOT OK{reset}")
        print(f"{red}o terceiro argumento de funções inscritas em eventos locais deve ter o tipo declarado{reset}")
        numeroErros += 1
    else:
        if not checarClasseHerdaDeEvent(SomeEvent):
            print(f"o tipo do terceiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset}, {yellow}{SomeEvent}{reset} deve ser um evento - {red}NOT OK{reset}")
            print(f"{red}o terceiro argumento de funções inscritas em eventos locais deve ser um evento{reset}")
            numeroErros += 1

    if not saida:
        print(f"função {yellow}{nomeFuncao}{reset} precisa ter saida void - {red}NOT OK{reset}")
        print(f"{red}funções inscritas em eventos locais devem retornar void{reset}")
        numeroErros += 1
    else:
        if void != "void":
            print(f"saida {yellow}{void}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"void\" - {red}NOT OK{reset}")
            print(f"{red}funções inscritas em eventos locais devem retornar void{reset}")
            numeroErros += 1

    return numeroErros

def checarFuncaoEventoGlobal(linha: str, nomeFuncao: str) -> int:
    numeroErros = 0

    # matches the line: static func [Something]([something]: [something]) -> void:
    matchFunc = re.search(r"(static)?\s*func\s+(\w+)\s*\(\s*(\w+)(\s*:\s*(\w+))?\s*\)(\s*->\s*(\w+))?\s*:", linha)
    if not matchFunc:
        print(f"função {yellow}{nomeFuncao}{reset} inscrita em um evento global não segue padrão - {red}NOT OK{reset}")
        print(f"{red}funções inscritas em eventos locais devem ter o padrão: \"static func [nomeFunção](_args: [SomeEvent]) -> void:\"{reset}")
        numeroErros += 1
        return numeroErros
    
    static = matchFunc.group(1)
    _args = matchFunc.group(3)
    type_1 = matchFunc.group(4)
    SomeEvent = matchFunc.group(5)
    saida = matchFunc.group(6)
    void = matchFunc.group(7)

    if not static:
        print(f"função {yellow}{nomeFuncao}{reset} não é estática - {red}NOT OK{reset}")
        print(f"{red}todas as funções de sistemas devem ser estáticas!{reset}")
        numeroErros += 1
    
    if _args != "_args":
        print(f"primeiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"_args\" - {red}NOT OK{reset}")
        print(f"{red}o primeiro argumento de funções inscritas em eventos globais deve ser \"_args\"{reset}")
        numeroErros += 1
    
    if not type_1:
        print(f"primeiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset} precisa de um tipo declarado - {red}NOT OK{reset}")
        print(f"{red}o primeiro argumento de funções inscritas em eventos globais deve ter o tipo declarado{reset}")
        numeroErros += 1
    else:
        if not checarClasseHerdaDeEvent(SomeEvent):
            print(f"o tipo do primeiro argumento {yellow}{_args}{reset} da função {yellow}{nomeFuncao}{reset}, {yellow}{SomeEvent}{reset} deve ser um evento - {red}NOT OK{reset}")
            print(f"{red}o primeiro argumento de funções inscritas em eventos globais deve ser um evento{reset}")
            numeroErros += 1

    if not saida:
        print(f"função {yellow}{nomeFuncao}{reset} precisa ter saida void - {red}NOT OK{reset}")
        print(f"{red}funções inscritas em eventos globais devem retornar void{reset}")
        numeroErros += 1
    else:
        if void != "void":
            print(f"saida {yellow}{void}{reset} da função {yellow}{nomeFuncao}{reset} diferente de \"void\" - {red}NOT OK{reset}")
            print(f"{red}funções inscritas em eventos globais devem retornar void{reset}")
            numeroErros += 1

    return numeroErros

if __name__ == "__main__":
    main()
