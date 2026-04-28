from pathlib import Path
import sys
import re

from godot_scripts_check_inheritance import checarClasseHerdaDeComponent
from ecs_check_internal_class import checarNomeClasseInterna
from ecs_check_internal_class import checarHerancaClasseInterna

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts/game")
    numeroErros = 0
    numeroComponentesChecados = 0

    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_component.gd"):
            numeroErros += checarComponente(arquivo)
            numeroComponentesChecados += 1

    print(f"{numeroComponentesChecados} componentes checados. número de problemas: {green if numeroErros == 0 else red}{numeroErros}{reset}")
    sys.exit(numeroErros)

def checarComponente(arquivo: Path) -> int:
    numeroErros = 0

    linhas = arquivo.read_text().split("\n")

    nomeClasse = None
    nomeClasseInterna = None

    nomeArquivo = arquivo.name.removesuffix("_component.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "Component"

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

            if not nomeClasseInterna and not checarClasseHerdaDeComponent(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} não herda de {yellow}Component{reset} - {red}NOT OK{reset}")
                print(f"{red}todos os componentes devem herdar de Component (mesmo que indiretamente)!{reset}")
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
                    print(f"{red}componentes só podem ter a função _init!{reset}")
                    numeroErros += 1
                else:
                    print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseInterna}{reset} - {red}NOT OK{reset}")
                    print(f"{red}classes internas só podem ter a função _init!{reset}")
                    numeroErros += 1

    if not nomeClasse:
        print(f"não encontrado linha com {yellow}class_name {nomeClassePadrao}{reset} - {red}NOT OK{reset}")
        print(f"{red}arquivos de componente devem declarar a classe daquele componente!{reset}")
        numeroErros += 1

    print(f"arquivo componente: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

if __name__ == "__main__":
    main()
