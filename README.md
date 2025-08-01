# linux_shortcuts
Developed by Nem Tudo

How to install:

Install the commands:
 - Install: `sudo nano /usr/local/bin/[command]`
 - Make executable: `chmod +x /usr/local/bin/[command]`

Install the autocomplete:
- Install: `sudo nano /etc/bash_completion.d/[command]`
- Reload: `source /etc/bash_completion.d/[command]`

# Commands

# Nginx Manager

🔧 **Ferramenta de linha de comando para gerenciamento simplificado do Nginx**

## 📋 Índice

- [Português](#português)
- [English](#english)

---

## Português

### 🔄 Controle de Serviço

| Comando | Descrição |
|---------|-----------|
| `nx start` | Inicia o Nginx |
| `nx stop` | Para o Nginx |
| `nx restart` | Reinicia o Nginx |
| `nx reload` | Recarrega configurações |
| `nx status` | Status do serviço |
| `nx test` | Testa configurações |

### 📋 Listagem

| Comando | Descrição |
|---------|-----------|
| `nx enabled` | Lista sites habilitados |
| `nx list` | Lista sites habilitados (alias) |
| `nx available` | Lista sites disponíveis |

### 🌐 Gerenciamento de Sites

| Comando | Descrição |
|---------|-----------|
| `nx create SITE [PORTA]` | Cria novo proxy reverso |
| `nx edit SITE` | Edita configuração do site |
| `nx remove SITE` | Remove site completamente |
| `nx siteenable SITE` | Habilita site |
| `nx sitedisable SITE` | Desabilita site |

### 🔒 SSL/Certificados

| Comando | Descrição |
|---------|-----------|
| `nx certbot DOMINIO` | Configura SSL com Certbot |

### 💾 Backup

| Comando | Descrição |
|---------|-----------|
| `nx backup SITE` | Cria backup da configuração |

### 📄 Logs

| Comando | Descrição |
|---------|-----------|
| `nx logs` | Mostra logs de erro |
| `nx access-logs` | Mostra access logs |
| `nx help` | Mostra ajuda |

### 📖 Exemplos de Uso

```bash
# Iniciar o Nginx
nx start

# Criar um novo site proxy reverso na porta 3000
nx create meusite.com 3000

# Habilitar um site
nx siteenable meusite.com

# Configurar SSL
nx certbot meusite.com

# Ver status do serviço
nx status
```

---

## English

### 🔄 Service Control

| Command | Description |
|---------|-------------|
| `nx start` | Start Nginx |
| `nx stop` | Stop Nginx |
| `nx restart` | Restart Nginx |
| `nx reload` | Reload configurations |
| `nx status` | Service status |
| `nx test` | Test configurations |

### 📋 Listing

| Command | Description |
|---------|-------------|
| `nx enabled` | List enabled sites |
| `nx list` | List enabled sites (alias) |
| `nx available` | List available sites |

### 🌐 Site Management

| Command | Description |
|---------|-------------|
| `nx create SITE [PORT]` | Create new reverse proxy |
| `nx edit SITE` | Edit site configuration |
| `nx remove SITE` | Remove site completely |
| `nx siteenable SITE` | Enable site |
| `nx sitedisable SITE` | Disable site |

### 🔒 SSL/Certificates

| Command | Description |
|---------|-------------|
| `nx certbot DOMAIN` | Configure SSL with Certbot |

### 💾 Backup

| Command | Description |
|---------|-------------|
| `nx backup SITE` | Create configuration backup |

### 📄 Logs

| Command | Description |
|---------|-------------|
| `nx logs` | Show error logs |
| `nx access-logs` | Show access logs |
| `nx help` | Show help |

### 📖 Usage Examples

```bash
# Start Nginx
nx start

# Create a new reverse proxy site on port 3000
nx create mysite.com 3000

# Enable a site
nx siteenable mysite.com

# Configure SSL
nx certbot mysite.com

# Check service status
nx status
```

## 📝 Requirements

- Nginx
- Certbot (for SSL)
- Root/sudo privileges

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.