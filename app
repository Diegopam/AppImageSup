#!/bin/bash

JSON_URL="https://raw.githubusercontent.com/Diegopam/AppImageSup/main/apm.json"
BIN_DIR="/usr/local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
INSTALLED_JSON="$HOME/.config/AppImageStore/instalados.json"

sudo mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR" "$ICON_DIR" "$(dirname "$INSTALLED_JSON")"

baixar_json() {
  curl -s "$JSON_URL"
}

buscar_app_bloco() {
  baixar_json | awk -v RS='},' -v IGNORECASE=1 "/\"name\": *\"$1\"/ {print \$0 \"}\"}"
}

extrair_campo() {
  echo "$1" | grep -oP "\"$2\"\\s*:\\s*\"\\K[^\"]+"
}

carregar_lista_instalados() {
  if [ -f "$INSTALLED_JSON" ]; then
    cat "$INSTALLED_JSON"
  else
    echo "[]" > "$INSTALLED_JSON"
    echo "[]"
  fi
}

adicionar_app_instalado() {
  local APP_NAME="$1"
  local lista
  lista=$(carregar_lista_instalados | jq --arg name "$APP_NAME" 'if . | index($name) then . else . + [$name] end')
  echo "$lista" > "$INSTALLED_JSON"
}

remover_app_instalado_lista() {
  local APP_NAME="$1"
  local lista
  lista=$(carregar_lista_instalados | jq --arg name "$APP_NAME" 'del(.[index($name)])')
  echo "$lista" > "$INSTALLED_JSON"
}

criar_launcher() {
  local NAME="$1"
  local DESC="$2"
  local EXEC="$3"
  local ICON="$4"
  local CATEGORY="$5"
  local FILE="$DESKTOP_DIR/${NAME,,}.desktop"

  cat > "$FILE" <<EOF
[Desktop Entry]
Name=$NAME
Comment=$DESC
Exec=$EXEC
Icon=$ICON
Terminal=false
Type=Application
Categories=$CATEGORY;
StartupNotify=true
EOF

  chmod +x "$FILE"
  echo "✅ Launcher criado em $FILE"
}

instalar_app() {
  local APP_NAME="$1"
  local APP_BLOCK
  APP_BLOCK=$(buscar_app_bloco "$APP_NAME")

  if [ -z "$APP_BLOCK" ]; then
    echo "❌ App \"$APP_NAME\" não encontrado no repositório."
    exit 1
  fi

  local NAME URL ICON_URL DESC CATEGORY
  NAME=$(extrair_campo "$APP_BLOCK" "name")
  URL=$(extrair_campo "$APP_BLOCK" "url")
  ICON_URL=$(extrair_campo "$APP_BLOCK" "icon")
  DESC=$(extrair_campo "$APP_BLOCK" "description")
  CATEGORY=$(extrair_campo "$APP_BLOCK" "category")
  [ -z "$CATEGORY" ] && CATEGORY="Utility"

  local FILENAME DEST ICON_PATH
  FILENAME=$(basename "$URL")
  DEST="$BIN_DIR/$FILENAME"
  ICON_PATH="$ICON_DIR/$NAME.png"

  echo "🔽 Baixando $NAME..."
  curl -L "$URL" -o "/tmp/$FILENAME"
  sudo mv "/tmp/$FILENAME" "$DEST"
  sudo chmod +x "$DEST"
  echo "✅ App salvo em $DEST"

  if [ -n "$ICON_URL" ]; then
    echo "🎨 Baixando ícone..."
    curl -sL "$ICON_URL" -o "$ICON_PATH"
  else
    ICON_PATH=""
  fi

  criar_launcher "$NAME" "$DESC" "$DEST" "$ICON_PATH" "$CATEGORY"

  adicionar_app_instalado "$NAME"
}

listar_apps() {
  echo "📦 Lista de apps disponíveis:"
  local apps=($(baixar_json | grep -oP '"name"\s*:\s*"\K[^"]+' | sort))
  local total=${#apps[@]}
  local metade=$(( (total + 1) / 2 ))

  for ((i = 0; i < metade; i++)); do
    printf "  %-30s" "${apps[i]}"
    if [ $((i + metade)) -lt $total ]; then
      printf " %s" "${apps[i + metade]}"
    fi
    echo
  done
}

buscar_apps() {
  local TERMO="$1"
  echo "🔍 Resultados para \"$TERMO\":"
  baixar_json | grep -iPo '"name"\s*:\s*"\K[^"]+' | grep -i "$TERMO" || echo "Nada encontrado."
}

atualizar_app() {
  local APP_NAME="$1"
  local APP_BLOCK
  APP_BLOCK=$(buscar_app_bloco "$APP_NAME")

  if [ -z "$APP_BLOCK" ]; then
    echo "❌ App \"$APP_NAME\" não encontrado no repositório."
    return
  fi

  local NAME URL
  NAME=$(extrair_campo "$APP_BLOCK" "name")
  URL=$(extrair_campo "$APP_BLOCK" "url")
  FILENAME=$(basename "$URL")
  DEST="$BIN_DIR/$FILENAME"

  if [ -f "$DEST" ]; then
    echo "🔁 Atualizando $NAME..."
    curl -L "$URL" -o "/tmp/$FILENAME"
    sudo mv "/tmp/$FILENAME" "$DEST"
    sudo chmod +x "$DEST"
    echo "✅ Atualizado: $DEST"
  else
    echo "⚠️ $NAME não instalado. Ignorado."
  fi
}

atualizar_todos() {
  echo "🔄 Atualizando todos os apps instalados..."
  carregar_lista_instalados | jq -r '.[]' | while read -r app; do
    atualizar_app "$app"
  done
}

remover_app() {
  local APP_NAME="$1"
  local APP_BLOCK
  APP_BLOCK=$(buscar_app_bloco "$APP_NAME")

  if [ -z "$APP_BLOCK" ]; then
    echo "❌ App \"$APP_NAME\" não encontrado no repositório."
    exit 1
  fi

  local NAME URL
  NAME=$(extrair_campo "$APP_BLOCK" "name")
  URL=$(extrair_campo "$APP_BLOCK" "url")
  FILENAME=$(basename "$URL")
  DEST="$BIN_DIR/$FILENAME"
  DESKTOP_FILE="$DESKTOP_DIR/${NAME,,}.desktop"
  ICON_FILE="$ICON_DIR/$NAME.png"

  echo "🗑️ Removendo $NAME..."

  [ -f "$DEST" ] && sudo rm -f "$DEST" && echo "✅ AppImage removido: $DEST"
  [ -f "$DESKTOP_FILE" ] && rm -f "$DESKTOP_FILE" && echo "✅ Atalho removido: $DESKTOP_FILE"
  [ -f "$ICON_FILE" ] && rm -f "$ICON_FILE" && echo "✅ Ícone removido: $ICON_FILE"

  remover_app_instalado_lista "$NAME"
  echo "✔️ Remoção completa."
}

# ========== INTERPRETAÇÃO DE COMANDOS ==========
case "$1" in
  list)
    listar_apps
    ;;
  search)
    shift
    buscar_apps "$*"
    ;;
  install)
    shift
    instalar_app "$*"
    ;;
  update)
    shift
    if [[ "$1" == "--all" ]]; then
      atualizar_todos
    else
      atualizar_app "$*"
    fi
    ;;
  remove)
    shift
    remover_app "$*"
    ;;
  ""|help|-h|--help)
    echo "Uso:"
    echo "  app list                   → Lista todos os apps"
    echo "  app search <termo>        → Busca por nome"
    echo "  app install <nome>        → Instala AppImage"
    echo "  app update <nome>         → Atualiza AppImage específico"
    echo "  app update --all          → Atualiza todos os instalados"
    echo "  app remove <nome>         → Remove AppImage, atalho e ícone"
    ;;
  *)
    echo "❌ Comando inválido. Use: app help"
    ;;
esac

