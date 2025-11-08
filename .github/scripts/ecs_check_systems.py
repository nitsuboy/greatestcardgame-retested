from pathlib import Path
import re

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts")
    all_good = True

    for arquivo in root.rglob("*"):
        good = True

        if arquivo.name.endswith("_system.gd"):
            good = checarSistema(arquivo)
            all_good = False if not good else all_good

    return 0 if all_good else 1

def checarSistema(arquivo: Path) -> bool:
    all_good = True

    linhas = arquivo.read_text().split("\n")

    nomeClasse = "?"
    
    nomeArquivo = arquivo.name.removesuffix("_system.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "System"

    dentroFuncao = False

    for index, linha in enumerate(linhas):
        linhaNumero = index + 1

        # matches the line: class_name [Something] extends [Otherthing]
        matchClassName = re.search(r"class_name\s+(\w+)(?:\s+extends\s+(\w+))?", linha)
        if matchClassName:
            nomeClasse = matchClassName.group(1)
            nomeClassePai = matchClassName.group(2)

            if nomeClasse != nomeClassePadrao:
                print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasse}{reset} diferente do padrão: {yellow}{nomeClassePadrao}{reset} - {red}NOT OK{reset}")
                print(f"{red}o nome da classe deve seguir o padrão do nome do arquivo!{reset}")
                all_good = False
            
            if nomeClassePai and nomeClassePai != "System":
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}System{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os sistemas devem herdar de System!{reset}")
                all_good = False
        
        # matches the line: extends [Something]
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if nomeClassePai and nomeClassePai != "System":
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}System{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os sistemas devem herdar de System!{reset}")
                all_good = False

        # matches the line: static func [Something]
        matchStaticFunc = re.search(r"(static)?\s*func\s+(\w+)", linha)
        if matchStaticFunc:
            static = matchStaticFunc.group(1)
            nomeFuncao = matchStaticFunc.group(2)

            dentroFuncao = True

            if not static:
                print(f"linha {linhaNumero}: função {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} não é estática - {red}NOT OK{reset}")
                print(f"{red}todas as funções de sistemas devem ser estáticas!{reset}")
                all_good = False
        
        # matches the line: var [Something]
        matchVar = re.search(r"(\t+)?var\s+(\w+)", linha)
        if matchVar:
            tabs = matchVar.group(1)
            nomeVar = matchVar.group(2)

            if not tabs or not dentroFuncao:
                print(f"linha {linhaNumero}: variável {yellow}{nomeVar}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
                print(f"{red}sistemas não podem ter variáveis!{reset}")
                all_good = False

    print(f"arquivo sistema: {yellow}{arquivo.name}{reset} - {green if all_good else red}{"OK" if all_good else "NOT OK"}{reset}")
    return all_good

if __name__ == "__main__":
    main()
