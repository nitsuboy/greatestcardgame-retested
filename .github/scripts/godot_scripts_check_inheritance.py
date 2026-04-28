from pathlib import Path
import re

def checarClasseHerdaDeSystem(nomeClasse: str) -> bool:
    return checarClasseHerdaDe(nomeClasse, "System", ["system.gd"], True)

def checarClasseHerdaDeComponent(nomeClasse: str) -> bool:
    return checarClasseHerdaDe(nomeClasse, "Component", ["component.gd"])

def checarClasseHerdaDeEvent(nomeClasse: str) -> bool:
    return checarClasseHerdaDe(nomeClasse, "Event", ["event.gd"])

def checarClasseHerdaDe(nomeClasse: str, nomeClasseAncestral: str, terminacoesArquivo: list[str], diretamente=False) -> bool:
    root = Path("scripts")

    if nomeClasse == nomeClasseAncestral:
        return True
    
    for arquivo in root.rglob("*"):

        proximoArquivo = False
        for terminacaoArquivo in terminacoesArquivo:
            if not arquivo.name.endswith(terminacaoArquivo):
                proximoArquivo = True
                break
        if proximoArquivo:
            continue

        linhas = arquivo.read_text().split("\n")

        nomeClasseDentroArquivo = None

        for linha in linhas:
            # matches the line: class_name [Something]
            matchClassName = re.search(r"class_name\s+(\w+)", linha)
            if matchClassName:
                nomeClasseDentroArquivo = matchClassName.group(1)

            # matches the line: class [Something]
            matchClassName = re.search(r"class\s+(\w+)", linha)
            if matchClassName:
                nomeClasseDentroArquivo = matchClassName.group(1)

            # matches the line: extends [Something]
            matchClassParent = re.search(r"extends\s+(\w+)", linha)
            if matchClassParent:
                nomeClassePaiDentroArquivo = matchClassParent.group(1)

                if nomeClasseDentroArquivo != nomeClasse:
                    continue

                if diretamente:
                    return nomeClassePaiDentroArquivo == nomeClasseAncestral
                elif checarClasseHerdaDe(nomeClassePaiDentroArquivo, nomeClasseAncestral, terminacaoArquivo):
                    return True

    return False
