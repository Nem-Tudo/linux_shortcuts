#!/bin/bash

# Nginx Manager Script
# Salve como /usr/local/bin/nx e torne executável com: chmod +x /usr/local/bin/nx

case "$1" in
    start)
        echo "🚀 Iniciando Nginx..."
        sudo systemctl start nginx
        ;;
    stop)
        echo "🛑 Parando Nginx..."
        sudo systemctl stop nginx
        ;;
    restart)
        echo "🔄 Reiniciando Nginx..."
        sudo systemctl restart nginx
        ;;
    reload)
        echo "⚡ Recarregando Nginx..."
        sudo systemctl reload nginx
        ;;
    status)
        sudo systemctl status nginx
        ;;
    test)
        echo "🧪 Testando configuração..."
        sudo nginx -t
        ;;
    enabled|list)
        echo "📋 Sites habilitados:"
        ls -la /etc/nginx/sites-enabled/
        ;;
    available)
        echo "📋 Sites disponíveis:"
        ls -la /etc/nginx/sites-available/
        ;;
    siteenable)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx siteenable nome_do_site"
            exit 1
        fi
        
        SITE_NAME="$2"
        SITE_PATH="/etc/nginx/sites-available/$SITE_NAME"
        
        if [ ! -f "$SITE_PATH" ]; then
            echo "❌ Site $SITE_NAME não encontrado em sites-available"
            exit 1
        fi
        
        if [ -L "/etc/nginx/sites-enabled/$SITE_NAME" ]; then
            echo "⚠️  Site $SITE_NAME já está habilitado"
            exit 0
        fi
        
        echo "✅ Habilitando site: $SITE_NAME"
        sudo ln -s "$SITE_PATH" "/etc/nginx/sites-enabled/"
        
        if sudo nginx -t >/dev/null 2>&1; then
            echo "✅ Site habilitado com sucesso!"
            read -p "🔄 Deseja recarregar o Nginx agora? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo systemctl reload nginx
                echo "✅ Nginx recarregado!"
            fi
        else
            echo "❌ Erro na configuração!"
            sudo nginx -t
        fi
        ;;
    sitedisable)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx sitedisable nome_do_site"
            exit 1
        fi
        
        SITE_NAME="$2"
        
        if [ ! -L "/etc/nginx/sites-enabled/$SITE_NAME" ]; then
            echo "⚠️  Site $SITE_NAME não está habilitado"
            exit 0
        fi
        
        echo "🚫 Desabilitando site: $SITE_NAME"
        sudo rm -f "/etc/nginx/sites-enabled/$SITE_NAME"
        echo "✅ Site desabilitado!"
        
        read -p "🔄 Deseja recarregar o Nginx agora? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            sudo systemctl reload nginx
            echo "✅ Nginx recarregado!"
        fi
        ;;
    certbot)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx certbot dominio.com"
            exit 1
        fi
        
        DOMAIN="$2"
        
        echo "🔒 Configurando SSL para: $DOMAIN"
        echo "⚠️  Certifique-se de que o domínio está apontando para este servidor!"
        
        read -p "🚀 Continuar com o Certbot? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo certbot --nginx -d "$DOMAIN"
        else
            echo "❌ Operação cancelada."
        fi
        ;;
    backup)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx backup nome_do_site"
            exit 1
        fi
        
        SITE_NAME="$2"
        SITE_PATH="/etc/nginx/sites-available/$SITE_NAME"
        
        if [ ! -f "$SITE_PATH" ]; then
            echo "❌ Site $SITE_NAME não encontrado em sites-available"
            exit 1
        fi
        
        BACKUP_DIR="/etc/nginx/backups"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_FILE="$BACKUP_DIR/${SITE_NAME}_${TIMESTAMP}.bak"
        
        # Cria diretório de backup se não existir
        sudo mkdir -p "$BACKUP_DIR"
        
        # Cria o backup
        sudo cp "$SITE_PATH" "$BACKUP_FILE"
        
        echo "💾 Backup criado: $BACKUP_FILE"
        echo "📋 Backups disponíveis para $SITE_NAME:"
        sudo ls -la "$BACKUP_DIR" | grep "$SITE_NAME"
        ;;
    edit)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx edit nome_do_site"
            exit 1
        fi
        sudo nano "/etc/nginx/sites-available/$2"
        ;;
    create)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx create nome_do_site [porta]"
            exit 1
        fi
        
        SITE_NAME="$2"
        PORT="${3:-3000}"
        SITE_PATH="/etc/nginx/sites-available/$SITE_NAME"
        
        echo "🆕 Criando site: $SITE_NAME (porta: $PORT)"
        
        # Verifica se já existe
        if [ -f "$SITE_PATH" ]; then
            echo "⚠️  Site $SITE_NAME já existe!"
            read -p "Deseja sobrescrever? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "❌ Operação cancelada."
                exit 1
            fi
        fi
        
        # Cria o arquivo de configuração
        sudo tee "$SITE_PATH" > /dev/null <<EOF
server {
    listen 80;
    server_name $SITE_NAME;
    
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        # Habilita o site
        sudo ln -sf "$SITE_PATH" "/etc/nginx/sites-enabled/"
        
        # Testa a configuração
        if sudo nginx -t >/dev/null 2>&1; then
            echo "✅ Site $SITE_NAME criado com sucesso!"
            echo "📝 Configuração: $SITE_PATH"
            echo "🔗 Habilitado em sites-enabled"
            
            read -p "🔄 Deseja recarregar o Nginx agora? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo systemctl reload nginx
                echo "✅ Nginx recarregado!"
            fi
            
            # Pergunta sobre SSL
            echo
            read -p "🔒 Deseja configurar SSL com Certbot para $SITE_NAME? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🚀 Executando Certbot..."
                sudo certbot --nginx -d "$SITE_NAME"
            fi
        else
            echo "❌ Erro na configuração!"
            sudo nginx -t
        fi
        ;;
    remove|delete)
        if [ -z "$2" ]; then
            echo "❌ Uso: nx remove nome_do_site"
            exit 1
        fi
        
        SITE_NAME="$2"
        
        echo "🗑️  Removendo site: $SITE_NAME"
        echo "⚠️  Esta ação irá remover:"
        echo "   - Link simbólico em sites-enabled"
        echo "   - Arquivo de configuração em sites-available"
        echo
        
        read -p "❓ Tem certeza que deseja continuar? Digite 'sim' para confirmar: " CONFIRM
        
        if [ "$CONFIRM" != "sim" ]; then
            echo "❌ Operação cancelada."
            exit 0
        fi
        
        # Cria backup antes de remover
        if [ -f "/etc/nginx/sites-available/$SITE_NAME" ]; then
            echo "💾 Criando backup antes de remover..."
            BACKUP_DIR="/etc/nginx/backups"
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            BACKUP_FILE="$BACKUP_DIR/${SITE_NAME}_removed_${TIMESTAMP}.bak"
            
            sudo mkdir -p "$BACKUP_DIR"
            sudo cp "/etc/nginx/sites-available/$SITE_NAME" "$BACKUP_FILE"
            echo "📁 Backup salvo em: $BACKUP_FILE"
        fi
        
        # Remove o link simbólico
        if [ -L "/etc/nginx/sites-enabled/$SITE_NAME" ]; then
            sudo rm -f "/etc/nginx/sites-enabled/$SITE_NAME"
            echo "🔗 Link simbólico removido"
        fi
        
        # Remove o arquivo de configuração
        if [ -f "/etc/nginx/sites-available/$SITE_NAME" ]; then
            sudo rm -f "/etc/nginx/sites-available/$SITE_NAME"
            echo "📄 Arquivo de configuração removido"
        fi
        
        echo "✅ Site $SITE_NAME removido completamente!"
        
        read -p "🔄 Deseja recarregar o Nginx agora? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            sudo systemctl reload nginx
            echo "✅ Nginx recarregado!"
        fi
        ;;
    logs)
        echo "📄 Logs do Nginx (Ctrl+C para sair):"
        sudo tail -f /var/log/nginx/error.log
        ;;
    access-logs)
        echo "📄 Access Logs do Nginx (Ctrl+C para sair):"
        sudo tail -f /var/log/nginx/access.log
        ;;
    help|--help|-h)
        echo "🔧 Nginx Manager - Comandos disponíveis:"
        echo ""
        echo "🔄 Controle de Serviço:"
        echo "  nx start          - Inicia o Nginx"
        echo "  nx stop           - Para o Nginx"
        echo "  nx restart        - Reinicia o Nginx"
        echo "  nx reload         - Recarrega configurações"
        echo "  nx status         - Status do serviço"
        echo "  nx test           - Testa configurações"
        echo ""
        echo "📋 Listagem:"
        echo "  nx enabled        - Lista sites habilitados"
        echo "  nx list           - Lista sites habilitados (alias)"
        echo "  nx available      - Lista sites disponíveis"
        echo ""
        echo "🌐 Gerenciamento de Sites:"
        echo "  nx create SITE [PORTA] - Cria novo proxy reverso"
        echo "  nx edit SITE      - Edita configuração do site"
        echo "  nx remove SITE    - Remove site completamente"
        echo "  nx siteenable SITE - Habilita site"
        echo "  nx sitedisable SITE - Desabilita site"
        echo ""
        echo "🔒 SSL/Certificados:"
        echo "  nx certbot DOMINIO - Configura SSL com Certbot"
        echo ""
        echo "💾 Backup:"
        echo "  nx backup SITE    - Cria backup da configuração"
        echo ""
        echo "📄 Logs:"
        echo "  nx logs           - Mostra logs de erro"
        echo "  nx access-logs    - Mostra access logs"
        echo "  nx help           - Mostra esta ajuda"
        echo ""
        echo "Developed by nemtudo.me <3"
        ;;
    *)
        echo "❌ Comando não reconhecido: $1"
        echo "💡 Use 'nx help' para ver os comandos disponíveis"
        exit 1
        ;;
esac
