from pathlib import Path
import re

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts")
    numeroErros = 0

    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_event_args.gd"):
            numeroErros += checarArgumentoEventos(arquivo)

    print(f"todos os argumentos de evento checados. número de problemas: {green if numeroErros == 0 else red}{numeroErros}{reset}")
    return 0 if numeroErros == 0 else 1

def checarArgumentoEventos(arquivo: Path) -> int:
    numeroErros = 0

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

            if nomeClassePai and not checarClasseHerdaDeEventArgs(nomeClassePai):
                print(f"linha {linhaNumero}: classe pai: {yellow}{nomeClassePai}{reset} não herda de {yellow}EventArgs{reset} - {red}NOT OK{reset}")
                print(f"{red}todas os argumentos de evento devem herdar de EventArgs (mesmo que indiretamente)!{reset}")
                numeroErros += 1

        # matches the line: func [Something]
        matchFunc = re.search(r"func\s+(\w+)", linha)
        if matchFunc:
            nomeFuncao = matchFunc.group(1)

            if nomeFuncao != "_init":
                print(f"linha {linhaNumero}: função: {yellow}{nomeFuncao}{reset} dentro de {yellow}{nomeClasse}{reset} - {red}NOT OK{reset}")
                print(f"{red}argumentos de evento só podem ter a função _init{reset}")
                numeroErros += 1

        # matches the line: class [Something]
        matchClass = re.search(r"class\s+(\w+)", linha)
        if matchClass:
            nomeClasseSecundaria = matchClass.group(1)

            print(f"linha {linhaNumero}: classe secundaria {yellow}{nomeClasseSecundaria}{reset} dentro de {yellow}{arquivo.name}{reset} - {red}NOT OK{reset}")
            print(f"{red}só pode haver uma classe em arquivos de argumentos de evento!{reset}")
            numeroErros += 1

    print(f"arquivo argumento de evento: {yellow}{arquivo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    return numeroErros

def checarClasseHerdaDeEventArgs(nomeClassePai: str) -> bool:
    root = Path("scripts")

    if nomeClassePai == "EventArgs":
        return True

    for arquivo in root.rglob("*"):
        if arquivo.name.endswith("_event_args.gd") or arquivo.name.endswith("_event.gd"):
            linhas = arquivo.read_text().split("\n")

            arquivoNomeClasse = None

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
