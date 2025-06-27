# 🐧 APP - AppImage Package Manager

O **APP** é um gerenciador de AppImages leve, rápido e sem dependências externas.  
Com ele, você pode instalar, listar, atualizar, remover e buscar AppImages direto do terminal como se fosse um gerenciador de pacotes!

> ⚡ Totalmente feito em Bash e usando um arquivo JSON hospedado neste repositório como "repositório de apps".

---
## ⚠️ Atenção instale o jq antes de usar!
**jq para Arch Linux**
```bash
sudo pacman -S jq
```
**jq para Debian**
```bash
sudo apt install jq
```
**jq para Fedora**
```bash
sudo dnf install jq
```

## 📥 Instalação rápida

### 🔧 Instalar via `curl` (recomendado):

```bash
sudo curl -L https://raw.githubusercontent.com/Diegopam/AppImageSup/main/app -o /usr/local/bin/app && sudo chmod +x /usr/local/bin/app
```
### 🖥️ Comandos disponíveis:
**Listar AppImage Disponíveis**:
```bash
app list
```
**Pesquisar um AppImage no Repositório**:
o nome pode ser pesquisado pela metade, exemplo: Fire para Firefox, ou You para Youtube...
```bash
app search nome-do-app
```
**Instalar um AppImage**:
ao instalar ele ira estar listado em seus aplicativos dentro do seu menu de apps como qualquer outro aplicativo instalado.
```bash
app install nome-do-app
```
**Atualizar um AppImage**:
```bash
app update nome-do-app
```
**Atualizar todos os AppImage**:
```bash
app update --all
```
**Remover um AppImage**:
```bash
app remove nome-do-app
```
