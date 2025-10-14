#!/bin/bash
echo "Verificando estrutura e tipos de arquivos..."
# -------------------------------
# 🔧 CONFIGURAÇÃO
# -------------------------------

# Mapeamento: pasta → extensões permitidas
declare -A ALLOWED_EXTS=(
  ["scripts"]="gd uid"
  ["assets"]="png tres svg otf mp3 import"
  ["resources"]="tres"
  ["scenes"]="tscn"
)

# Arquivos permitidos na raiz
ALLOWED_ROOT_FILES=(
  ".editorconfig"
  ".gdignore"
  ".gitattributes"
  ".gitignore"
  "project.godot"
  "README.md"
)

# Pastas permitidas
ALLOWED_DIRS=("assets" "scripts" "resources" "docs" "scenes" ".github" ".git" ".godot" ".obsidian")

# -------------------------------
# 🚨 FUNÇÕES
# -------------------------------

# Checar arquivos da raiz
check_root() {
  echo "Checando arquivos na raiz..."
  for file in $(find . -maxdepth 1 -type f -printf "%f\n"); do
    if [[ ! " ${ALLOWED_ROOT_FILES[@]} " =~ " ${file} " ]]; then
      echo -e "\033[0;31mArquivo não permitido na raiz: $file\033[0m"
      exit 1
    fi
  done
}

# Checar pastas válidas
check_dirs() {
  echo "Checando pastas permitidas..."
  for dir in $(find . -maxdepth 1 -type d -printf "%f\n" | grep -vE "^\.$"); do
    if [[ ! " ${ALLOWED_DIRS[@]} " =~ " ${dir} " ]]; then
      echo -e "\033[0;31mPasta não permitida na raiz: $dir\033[0m"
      exit 1
    fi
  done
}

# Checar extensões dentro das pastas configuradas
check_extensions() {
  for dir in "${!ALLOWED_EXTS[@]}"; do
    if [ -d "$dir" ]; then
      allowed="${ALLOWED_EXTS[$dir]}"
      echo "Checando pasta '$dir'"
      while IFS= read -r -d '' file; do
        ext="${file##*.}"
        if [[ ! " ${allowed} " =~ " ${ext} " ]]; then
          echo -e "\033[0;31mArquivo inválido encontrado em '$dir': $file\033[0m"
          echo "   → Permitidos: $allowed"
          exit 1
        fi
      done < <(find "$dir" -type f -print0)
    fi
  done
}

# -------------------------------
# ▶️ EXECUÇÃO
# -------------------------------

check_root
check_dirs
check_extensions

echo -e "\033[0;32mVerificação concluída com sucesso! Todos os arquivos e pastas estão corretos.\033[0m"