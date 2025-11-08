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

        if arquivo.name.endswith("_component.gd"):
            good = checarComponente(arquivo)
            all_good = False if not good else all_good

    return 0 if all_good else 1

def checarComponente(arquivo: Path) -> bool:
    all_good = True

    linhas = arquivo.read_text().split("\n")

    nomeClasse = "?"
    
    nomeArquivo = arquivo.name.removesuffix("_component.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "Component"
    
    for index, linha in enumerate(linhas):
        linhaNumero = index + 1

        matchClassName = re.search(r"class_name\s+(\w+)(?:\s+extends\s+(\w+))?", linha)
        if matchClassName:
            nomeClasse = matchClassName.group(1)
            nomeClassePai = matchClassName.group(2)

            if nomeClasse != nomeClassePadrao:
                print(f"linha {linhaNumero}: nome classe: {yellow}{nomeClasse}{reset} diferente do padrão: {yellow}{nomeClassePadrao}{reset} - {red}NOT OK{reset}")
                all_good = False
            
            if nomeClassePai and nomeClassePai != "Component":
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}Component{reset} - {red}NOT OK{reset}")
                all_good = False
        
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if nomeClassePai and nomeClassePai != "Component":
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}Component{reset} - {red}NOT OK{reset}")
                all_good = False

        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)
            print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
            all_good = False

    print(f"arquivo componente: {yellow}{arquivo.name}{reset} - {green if all_good else red}{"OK" if all_good else "NOT OK"}{reset}")
    return all_good

if __name__ == "__main__":
    main()
