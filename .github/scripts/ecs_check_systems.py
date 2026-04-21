from pathlib import Path
import sys
import re

from godot_scripts_check_inheritance import checarClasseHerdaDeSystem
from ecs_check_internal_class import checarNomeClasseInterna
from ecs_check_internal_class import checarHerancaClasseInterna

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts")
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
                print(f"{red}todas os sistemas devem herdar diretamente de System!{reset}")
                numeroErros += 1
            elif nomeClasseInterna:
                numeroErros += checarHerancaClasseInterna(nomeClasseInterna, nomeClassePai, linhaNumero)

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
            elif nomeClasseInterna:
                print(f"linha {linhaNumero}: função {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseInterna}{reset} - {red}NOT OK{reset}")
                print(f"{red}classes internas não podem ter funções!{reset}")
                numeroErros += 1
        
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

if __name__ == "__main__":
    main()
