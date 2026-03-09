from pathlib import Path
import sys
import re

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts")
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
        
        # matches the line: extends [Something]
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if not checarClasseHerdaDeComponent(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} não herda de {yellow}Component{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os componentes devem herdar de Component (mesmo que indiretamente)!{reset}")
                numeroErros += 1

        # matches the line: func [Something]
        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)
            print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
            print(f"{red}componentes não podem ter funções!{reset}")
            numeroErros += 1

        # matches the line: class [Something]
        matchClass = re.search(r"class\s+(\w+)", linha)
        if matchClass:
            nomeClasseSecundaria = matchClass.group(1)

            print(f"linha {linhaNumero}: classe secundaria {yellow}{nomeClasseSecundaria}{reset} dentro de {yellow}{arquivo.name}{reset} - {red}NOT OK{reset}")
            print(f"{red}só pode haver uma classe em arquivos de componentes!{reset}")
            numeroErros += 1

    print(f"arquivo componente: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

def checarClasseHerdaDeComponent(nomeClassePai: str) -> bool:
    root = Path("scripts")

    if nomeClassePai == "Component":
        return True
    
    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_component.gd"):
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
                        return checarClasseHerdaDeComponent(arquivoNomeClassePai)

if __name__ == "__main__":
    main()
