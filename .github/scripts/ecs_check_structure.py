from pathlib import Path

red = "\033[31m"
green = "\033[32m"
yellow = "\033[33m"
reset = "\033[0m"

def main():
    root = Path("scripts")
    all_good = True

    for arquivo in root.rglob("*"):
        good = True

        if arquivo.name.endswith(".uid"):
            continue

        if arquivo.name.endswith("_event.gd") and arquivo.parent.name != "events":
            good, all_good = False, False
        if arquivo.name.endswith("_event_args.gd") and arquivo.parent.name != "events":
            good, all_good = False, False
        if arquivo.name.endswith("_component.gd") and arquivo.parent.name != "components":
            good, all_good = False, False
        if arquivo.name.endswith("_system.gd") and arquivo.parent.name != "systems":
            good, all_good = False, False

        print(f"Arquivo: {yellow}{arquivo.name}{reset} - Pasta acima: {yellow}{arquivo.parent.name}{reset} - {green + "OK" if good else red + "NOT OK"}{reset}")

    return 0 if all_good else 1

if __name__ == "__main__":
    main()
