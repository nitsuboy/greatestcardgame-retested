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

        if arquivo.name.endswith("_event_args.gd"):
            good = checarArgumentoEventos(arquivo)
            all_good = False if not good else all_good

    return 0 if all_good else 1

def checarArgumentoEventos(arquivo: Path) -> bool:
    all_good = True

    linhas = arquivo.read_text().split("\n")

    nomeClasse = None
    
    nomeArquivo = arquivo.name.removesuffix("_event_args.gd")
    indentificadores = nomeArquivo.split("_")
    nomeClassePadrao = ""
    for indentificador in indentificadores:
        nomeClassePadrao += indentificador.capitalize()
    nomeClassePadrao += "EventArgs"

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
            
            if nomeClassePai and not checarClasseHerdaDeEventArgs(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}Component{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os argumentos de evento devem herdar de EventArgs (mesmo que indiretamente)!{reset}")
                all_good = False
        
        # matches the line: extends [Something]
        matchClassParent = re.search(r"extends\s+(\w+)", linha)
        if matchClassParent:
            nomeClassePai = matchClassParent.group(1)

            if nomeClassePai and not checarClasseHerdaDeEventArgs(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} diferente de {yellow}Component{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os argumentos de evento devem herdar de EventArgs (mesmo que indiretamente)!{reset}")
                all_good = False

        # matches the line: func [Something]
        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)
            print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
            print(f"{red}argumentos de evento não podem ter funções!{reset}")
            all_good = False

        # matches the line: class [Something]
        matchClass = re.search(r"class\s+(\w+)", linha)
        if matchClass:
            nomeClasseSecundaria = matchClass.group(1)

            print(f"linha {linhaNumero}: classe secundaria {yellow}{nomeClasseSecundaria}{reset} dentro de {yellow}{arquivo.name}{reset} - {red}NOT OK{reset}")
            print(f"{red}só pode haver uma classe em arquivos de argumentos de evento!{reset}")
            all_good = False

    print(f"arquivo argumento de evento: {yellow}{arquivo.name}{reset} - {green if all_good else red}{"OK" if all_good else "NOT OK"}{reset}")
    return all_good

def checarClasseHerdaDeEventArgs(nomeClassePai: str) -> bool:
    root = Path("scripts")

    if nomeClassePai == "EventArgs":
        return True

    for arquivo in root.rglob("*"):
        linhas = arquivo.read_text().split("\n")

        arquivoNomeClasse = ""

        for linha in linhas:
            # matches the line: class_name [Something] extends [Otherthing]
            matchClassName = re.search(r"class_name\s+(\w+)(?:\s+extends\s+(\w+))?", linha)
            if matchClassName:
                arquivoNomeClasse = matchClassName.group(1)
                arquivoNomeClassePai = matchClassName.group(2)

                if arquivoNomeClasse == nomeClassePai:
                    return checarClasseHerdaDeEventArgs(arquivoNomeClassePai)
                
            # matches the line: class [Something] extends [Otherthing]
            matchClassName = re.search(r"class\s+(\w+)(?:\s+extends\s+(\w+))?", linha)
            if matchClassName:
                arquivoNomeClasse = matchClassName.group(1)
                arquivoNomeClassePai = matchClassName.group(2)

                if arquivoNomeClasse == nomeClassePai:
                    return checarClasseHerdaDeEventArgs(arquivoNomeClassePai)

            
            # matches the line: extends [Something]
            matchClassParent = re.search(r"extends\s+(\w+)", linha)
            if matchClassParent:
                arquivoNomeClassePai = matchClassParent.group(1)

                if arquivoNomeClasse == nomeClassePai:
                    return checarClasseHerdaDeEventArgs(arquivoNomeClassePai)
    
    return False


if __name__ == "__main__":
    main()
