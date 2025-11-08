from pathlib import Path

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def verificarModulo(modulo: Path) -> bool:
    all_good = True

    print("")
    print(f"MODULO: {yellow}{modulo.name}{reset}")

    for pasta in modulo.iterdir():
        if pasta.is_dir():
            if pasta.name not in ("components", "events", "systems"):
                print(f"pasta não padrão: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {red}NOT OK - PASTAS PADRÕES: \"components\", \"events\", \"systems\"{reset}")
                all_good = False
            else:
                print(f"pasta padrão: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {green}OK{reset}")
                for arquivo in pasta.iterdir():
                    if arquivo.is_dir():
                        print(f"pasta: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK - APENAS ARQUIVOS PERMITIDOS DENTRO DA PASTA: {pasta.name}{reset}")
                        all_good = False
                    else:
                        if arquivo.name.endswith(".uid"):
                            continue

                        if pasta.name == "components":
                            if arquivo.name.endswith("_component.gd"):
                                print(f"arquivo componente: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK - APENAS ARQUIVOS TERMINADOS EM \"_component.gd\" PERMITIDOS NA PASTA: {pasta.name}{reset}")
                                all_good = False

                        elif pasta.name == "events":
                            if arquivo.name.endswith("_event.gd"):
                                print(f"arquivo evento: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            elif arquivo.name.endswith("_event_args.gd"):
                                print(f"arquivo argumento de evento: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK - APENAS ARQUIVOS TERMINADOS EM \"_event.gd\" ou \"_event_args.gd\" PERMITIDOS NA PASTA: {pasta.name}{reset}")
                                all_good = False
        
                        elif pasta.name == "systems":
                            if arquivo.name.endswith("_system.gd"):
                                print(f"arquivo sistema: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {green}OK{reset}")
                            else:
                                print(f"arquivo: {yellow}{arquivo.name}{reset} dentro da pasta {yellow}{pasta.name}{reset} - {red}NOT OK - APENAS ARQUIVOS TERMINADOS EM \"_system.gd\" PERMITIDOS NA PASTA: {pasta.name}{reset}")
                                all_good = False
        else:
            # geralmente modulos não podem ter nenhum arquivo extra além das pastas components, events e systems. Com exceção do modulo ECS

            if modulo.name == "ECS" and pasta.name in (
                "component.gd", "component.gd.uid",
                "entity.gd", "entity.gd.uid",
                "event_args.gd", "event_args.gd.uid",
                "event.gd", "event.gd.uid",
                "system.gd", "system.gd.uid"):
                print(f"arquivo abstrato: {yellow}{pasta.name}{reset} dentro do modulo ECS - {green}OK{reset}")
                continue

            print(f"arquivo: {yellow}{pasta.name}{reset} dentro do modulo {yellow}{modulo.name}{reset} - {red}NOT OK - APENAS PASTAS PERMITIDAS DENTRO DO MODULOS{reset}")
            all_good = False

    print(f"MODULO: {yellow}{modulo.name}{reset} - {green if all_good else red}{"OK" if all_good else "NOT OK"}{reset}")
    print("")
    
    return all_good

def main():
    root = Path("scripts")
    all_good = True

    for pasta in root.iterdir():
        if pasta.is_dir():
            modulo = False

            # Se qualquer pasta tiver uma pasta components, events ou systems, é considerada um módulo
            for pastaInterna in pasta.iterdir():
                if pastaInterna.name in ("components", "events", "systems"):
                    modulo = True

            if modulo:
                print(f"pasta: {yellow}{pasta}{reset} é modulo")
                all_good = False if not verificarModulo(pasta) else all_good
            else:
                print(f"pasta: {yellow}{pasta}{reset} não é modulo")

    return 0 if all_good else 1

if __name__ == "__main__":
    main()
