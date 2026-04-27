from pathlib import Path
import sys
import re

from ecs_check_event_args import checarClasseHerdaDeEventArgs

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

    nomeClasseEvento = None
    nomeClasseArgumentoEvento = None

    dentroFuncao = False
    
    nomeArquivo = arquivo.name.removesuffix("_event.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClasseEventoPadrao = ""
    for indentificador in indentificadores:
        nomeClasseEventoPadrao += indentificador.capitalize()
    nomeClasseEventoPadrao += "Event"

    for index, linha in enumerate(linhas):
        linhaNumero = index + 1

        # matches the line: class_name [Something]
        matchClassName = re.search(r"class_name\s+(\w+)", linha)
        if matchClassName:
            nomeClasseEvento = matchClassName.group(1)

            if nomeClasseEvento != nomeClasseEventoPadrao:
                print(f"linha {linhaNumero}: nome classe de evento: {yellow}{nomeClasseEvento}{reset} diferente do padrão: {yellow}{nomeClasseEventoPadrao}{reset} - {red}NOT OK{reset}")
                print(f"{red}o nome da classe deve seguir o padrão do nome do arquivo!{reset}")
                numeroErros += 1

        # matches the line: class [Something]
        matchClass = re.search(r"class\s+(\w+)", linha)
        if matchClass:
            nomeClasseArgumentoEvento = matchClass.group(1)

            dentroFuncao = False

            matchRegularEventArgName = re.search(r"^([A-Z][a-z0-9]*)+EventArgs$", nomeClasseArgumentoEvento)

            if not matchRegularEventArgName:
                print(f"linha {linhaNumero}: nome classe de argumento de evento: {yellow}{nomeClasseArgumentoEvento}{reset} fora do padrão {yellow}CamelCaseEventArgs{reset} - {red}NOT OK{reset}")
                print(f"{red}o nome da classe de argumento de evento deve seguir o padrão \"CamelCaseEventArgs\"{reset}")
                numeroErros += 1

        # matches the line: extends [Something]
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if not nomeClasseArgumentoEvento:
                if not checarClasseHerdaDeEvent(nomeClassePai):
                    print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} de {yellow}{nomeClasseEvento}{reset} não herda de {yellow}Event{reset} - {red}NOT OK{reset}")
                    print(f"{red}todas os eventos devem herdar de Event (mesmo que indiretamente)!{reset}")
                    numeroErros += 1
            else:
                if not checarClasseHerdaDeEventArgs(nomeClassePai):
                    print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} de {yellow}{nomeClasseArgumentoEvento}{reset} não herda de {yellow}EventArgs{reset} - {red}NOT OK{reset}")
                    print(f"{red}todas os argumentos de evento devem herdar de EventArgs (mesmo que indiretamente)!{reset}")
                    numeroErros += 1

        # matches the line: func [Something]
        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)

            dentroFuncao = True

            if not nomeClasseArgumentoEvento:
                if nomeFuncao not in ("_init", "treat"):
                    print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseEvento}{reset} - {red}NOT OK{reset}")
                    print(f"{red}eventos só podem ter a função _init e treat{reset}")
                    numeroErros += 1
            else:
                if nomeFuncao != "_init":
                    print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasseArgumentoEvento}{reset} - {red}NOT OK{reset}")
                    print(f"{red}argumentos de evento só podem ter a função _init{reset}")
                    numeroErros += 1

        # matches the line: var [Something]
        matchVar = re.search(r"(\t+)?var\s+(\w+)", linha)
        if matchVar:
            tabs = matchVar.group(1)
            nomeVar = matchVar.group(2)

            if not nomeClasseArgumentoEvento:
                if not tabs or not dentroFuncao:
                    print(f"linha {linhaNumero}: variável {yellow}{nomeVar}{reset} dentro de {yellow}{nomeClasseEvento}{reset} - {red}NOT OK{reset}")
                    print(f"{red}eventos não podem ter variáveis!{reset}")
                    numeroErros += 1

    print(f"arquivo evento: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

def checarClasseHerdaDeEvent(nomeClassePai: str) -> bool:
    root = Path("scripts")

    if nomeClassePai == "Event":
        return True
    
    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_event.gd"):
            linhas = arquivo.read_text().split("\n")

            arquivoNomeClasse = None

            for linha in linhas:
                # matches the line: class_name [Something]
                matchClassName = re.search(r"class_name\s+(\w+)", linha)
                if matchClassName:
                    arquivoNomeClasse = matchClassName.group(1)
                
                # matches the line: extends [Something]
                matchClassParent = re.search(r"extends\s+(\w+)", linha)
                if matchClassParent:
                    arquivoNomeClassePai = matchClassParent.group(1)

                    if arquivoNomeClasse == nomeClassePai:
                        return checarClasseHerdaDeEventArgs(arquivoNomeClassePai)

if __name__ == "__main__":
    main()
