from pathlib import Path
import sys
import re

from godot_scripts_check_inheritance import checarClasseHerdaDeEvent
from ecs_check_internal_class import checarNomeClasseInterna
from ecs_check_internal_class import checarHerancaClasseInterna

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts/game")
    numeroErros = 0
    numeroEventosChecados = 0

    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_event.gd"):
            numeroErros += checarEventos(arquivo)
            numeroEventosChecados += 1

    print(f"{numeroEventosChecados} eventos checados. número de problemas: {green if numeroErros == 0 else red}{numeroErros}{reset}")
    sys.exit(numeroErros)

def checarEventos(arquivo: Path) -> int:
    numeroErros = 0

    linhas = arquivo.read_text().split("\n")

    nomeClasse = None
    nomeClasseInterna = None
    
    nomeArquivo = arquivo.name.removesuffix("_event.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "Event"

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

            if not nomeClasseInterna and not checarClasseHerdaDeEvent(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} não herda de {yellow}Event{reset} - {red}NOT OK{reset}")
                print(f"{red}todos os eventos devem herdar de Event (mesmo que indiretamente)!{reset}")
                numeroErros += 1
            elif nomeClasseInterna:
                numeroErros += checarHerancaClasseInterna(nomeClasseInterna, nomeClassePai, linhaNumero)

        # matches the line: func [Something]
        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)

            if nomeFuncao != "_init":
                if not nomeClasseInterna:
                    print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
                    print(f"{red}eventos só podem ter a função _init!{reset}")
                    numeroErros += 1
                else:
                    print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseInterna}{reset} - {red}NOT OK{reset}")
                    print(f"{red}classes internas só podem ter a função _init!{reset}")
                    numeroErros += 1

    if not nomeClasse:
        print(f"não encontrado linha com {yellow}class_name {nomeClassePadrao}{reset} - {red}NOT OK{reset}")
        print(f"{red}arquivos de evento devem declarar a classe daquele evento!{reset}")
        numeroErros += 1

    print(f"arquivo evento: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

if __name__ == "__main__":
    main()
