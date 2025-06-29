#!/bin/bash

# Autocomplete para o comando nx
# Salve como /etc/bash_completion.d/nx

_nx_completion() {
    local cur prev opts sites enabled_sites
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Comandos principais disponíveis
    opts="start stop restart reload status test enabled available list edit create remove delete logs access-logs help siteenable sitedisable certbot backup"
    
    # Se estamos completando o primeiro argumento (comando)
    if [[ ${COMP_CWORD} == 1 ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
    fi
    
    # Se estamos completando o segundo argumento
    case "${prev}" in
        edit|backup)
            # Para edit e backup, sugerir todos os sites disponíveis
            if [[ -d "/etc/nginx/sites-available" ]]; then
                sites=$(ls /etc/nginx/sites-available/ 2>/dev/null)
                COMPREPLY=($(compgen -W "${sites}" -- ${cur}))
            fi
            return 0
            ;;
        remove|delete|sitedisable)
            # Para remove/delete/sitedisable, sugerir apenas sites habilitados
            if [[ -d "/etc/nginx/sites-enabled" ]]; then
                enabled_sites=$(ls /etc/nginx/sites-enabled/ 2>/dev/null)
                COMPREPLY=($(compgen -W "${enabled_sites}" -- ${cur}))
            fi
            return 0
            ;;
        siteenable)
            # Para siteenable, sugerir sites disponíveis mas não habilitados
            if [[ -d "/etc/nginx/sites-available" && -d "/etc/nginx/sites-enabled" ]]; then
                available_sites=$(ls /etc/nginx/sites-available/ 2>/dev/null)
                enabled_sites=$(ls /etc/nginx/sites-enabled/ 2>/dev/null)
                # Sites que estão em available mas não em enabled
                sites=""
                for site in $available_sites; do
                    if [[ ! " $enabled_sites " =~ " $site " ]]; then
                        sites="$sites $site"
                    fi
                done
                COMPREPLY=($(compgen -W "${sites}" -- ${cur}))
            fi
            return 0
            ;;
        create)
            # Para create, sugerir alguns nomes comuns
            COMPREPLY=($(compgen -W "app api frontend backend admin dashboard blog site" -- ${cur}))
            return 0
            ;;
        certbot)
            # Para certbot, não há sugestões específicas (domínio livre)
            return 0
            ;;
    esac
    
    # Se estamos no terceiro argumento e o comando é create
    if [[ ${COMP_CWORD} == 3 && "${COMP_WORDS[1]}" == "create" ]]; then
        # Sugerir portas comuns organizadas por tipo
        local common_ports="3000 3001 8000 8080 5000 4000 9000 8888 7000 6000"
        COMPREPLY=($(compgen -W "${common_ports}" -- ${cur}))
        return 0
    fi
}

# Registra a função de autocomplete para o comando nx
complete -F _nx_completion nx