from pathlib import Path
import sys

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts/game")
    numeroErros = 0
    numeroModulosChecados = 0

    for pasta in root.iterdir():
        if pasta.is_dir():
            modulo = False

            # Se qualquer pasta tiver uma pasta components, events ou systems, é considerada um módulo
            for pastaInterna in pasta.iterdir():
                if pastaInterna.name in ("components", "events", "systems"):
                    modulo = True

            if modulo:
                print(f"pasta: {yellow}{pasta}{reset} é modulo")
                numeroErros += verificarModulo(pasta)
                numeroModulosChecados += 1
            else:
                print(f"pasta: {yellow}{pasta}{reset} não é modulo")

    print(f"{numeroModulosChecados} modulos checados. número de problemas: {green if numeroErros == 0 else red}{numeroErros}{reset}")
    sys.exit(numeroErros)

def verificarModulo(modulo: Path) -> bool:
    numeroErros = 0

    print("")
    print(f"MODULO: {yellow}{modulo.name}{reset}")

    for pasta in modulo.iterdir():
        if pasta.is_dir():
            if pasta.name not in ("components", "events", "systems"):
                print(f"pasta não padrão: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {red}NOT OK{reset}")
                print(f"{red}modulos devem ter apeanas as pastas \"components\", \"events\" e \"systems\"!{reset}")
                numeroErros += 1
            else:
                print(f"pasta padrão: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {green}OK{reset}")
                for arquivo in pasta.iterdir():
                    if arquivo.is_dir():
                        print(f"pasta: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK{reset}")
                        print(f"{red}nao devem haver pastas dentro das pastas \"components\", \"events\" e \"systems\"!{reset}")
                        numeroErros += 1
                    else:
                        if arquivo.name.endswith(".uid"):
                            continue

                        if pasta.name == "components":
                            if arquivo.name.endswith("_component.gd"):
                                print(f"arquivo componente: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK{reset}")
                                print(f"{red}todos os arquivos dentro de \"components\" tem que terminar com _component.gd!{reset}")
                                numeroErros += 1

                        elif pasta.name == "events":
                            if arquivo.name.endswith("_event.gd"):
                                print(f"arquivo evento: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            elif arquivo.name.endswith("_event_args.gd"):
                                print(f"arquivo argumento de evento: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK{reset}")
                                print(f"{red}todos os arquivos dentro de \"events\" tem que terminar com _event.gd ou _event_args.gd!{reset}")
                                numeroErros += 1
        
                        elif pasta.name == "systems":
                            if arquivo.name.endswith("_system.gd"):
                                print(f"arquivo sistema: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK{reset}")
                                print(f"{red}todos os arquivos dentro de \"systems\" tem que terminar com _system.gd!{reset}")
                                numeroErros += 1
        else:
            print(f"arquivo: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {red}NOT OK{reset}")
            print(f"{red}modulos devem ter apeanas as pastas!{reset}")
            numeroErros += 1

    print(f"MODULO: {yellow}{modulo.name}{reset} - {green+"OK" if numeroErros == 0 else red+"NOT OK - " + str(numeroErros) + " erros"}{reset}")
    print("")
    
    return numeroErros

if __name__ == "__main__":
    main()
