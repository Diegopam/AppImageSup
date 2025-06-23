# 🐧 APM - AppImage Package Manager

O **APM** é um gerenciador de AppImages leve, rápido e sem dependências externas.  
Com ele, você pode instalar, listar, atualizar, remover e buscar AppImages direto do terminal como se fosse um gerenciador de pacotes!

> ⚡ Totalmente feito em Bash e usando um arquivo JSON hospedado neste repositório como "repositório de apps".

---

## 📥 Instalação rápida

### 🔧 Instalar via `curl` (recomendado):

```bash
sudo curl -L https://raw.githubusercontent.com/Diegopam/AppImageSup/main/apm -o /usr/local/bin/apm && sudo chmod +x /usr/local/bin/apm
```
### 🖥️ Comandos disponíveis:
**Listar AppImage Disponíveis**:
```bash
apm list
```
**Pesquisar um AppImage no Repositório**:
o nome pode ser pesquisado pela metade, exemplo: Fire para Firefox, ou You para Youtube...
```bash
apm search nome-do-app
```
**Instalar um AppImage**:
ao instalar ele ira estar listado em seus aplicativos dentro do seu menu de apps como qualquer outro aplicativo instalado.
```bash
apm nome-do-app
```
**Atualizar um AppImage**:
```bash
apm update nome-do-app
```
**Remover um AppImage**:
```bash
apm remove nome-do-app
```
