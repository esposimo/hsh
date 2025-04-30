#!/bin/bash



# l'app va creata creando i 3 ambienti
# quando si crea, deve creare oltre ai file tf
# i file 
# backend.tfvars con il contenuto dove il valore di path è dinamico (prende il nome dell'app)
#   address = "127.0.0.1:18500"
#   scheme  = "http"
#   path    = "terraform/state/vault-config/dev"
#
# variables.tfvars
#   già valorizzato con le variabili di base
#
#
# remote_backend.json
#   con eventuali remote terraform state da utilizzare
#
# secrets.ini
#.  contiene 
#   transit_mount="sopskeys" <- statico, è sempre lui
#   transit_key="myproject" < nome dell'app
#   keyvault="myproject-kv" <- nome del kv che verrà creato dallo script stesso (insieme alla transit)
#
# secrets.json già crittografato con un valore di esempio
# config.json valori che possono essere in chiaro per l'applicazione
#
# 
# Dockerfile con il FROM in alto che contiene il nome dell'immagine
#
#

#
# create_app <name> -s -b|--build IMAGE -r|--remote REMOTE_JSON
# 


# Funzione per mostrare l'usage
usage() {
    printf "\nUsage: $0 COMMAND [OPTIONS]\n";
    printf "\n";
    printf "Comandi:\n";
    printf "  add\t\tAggiunge un applicazione\n";
    printf "  list\t\tElenca le applicazioni presenti\n";
    printf "  rm\t\tRimuove un'applicazione\n";
    printf "  help\t\tElenca l'help\n";
    exit 1
}

usage_app()
{
    printf "\nUsage: $0 app NAME [OPTIONS]\n";
    printf "\n";
    printf "Options:\n";
    printf "  -s|--secrets\t\tCrea i file utili per i secrets\n";
    printf "  -b|--build IMAGE\tIndica l'immagine da usare per il container. Implica l'utilizzo di --container-name\n";
    printf "     --container-name\tIndica il nome del container. Da usare solo se si usa -b|--build\n";
    printf "  -r|--remote FILENAME\tIndica eventuali file di stato di progetti remoti Terraform. Può essere ripetuto\n";
    exit 1;
}
usage_list()
{
    printf "\nUsage $0 list\n\n";
    printf "Elenca la lista delle applicazioni\n\n";
    exit 1;
}

usage_rm()
{
    printf "\nUsage $0 rm NAME\n\n";
    printf "Elimina l'applicazione NAME\n\n";
    exit 1;
}

# Verifica che almeno una azione sia passata
if [ -z "$1" ]; then
    usage
fi

# Leggo l'azione (add|rm|list)
ACTION=$1
shift

# Gestione dell'azione
case $ACTION in
    help)
        if [[ $1 == "add" ]]; then
            usage_app;
        fi;
        if [[ $1 == "list" ]]; then
            usage_list;
        fi;
        if [[ $1 == "rm" ]]; then
            usage_rm;
        fi;
        usage;
        ;;
    list)
        if [ $# -gt 0 ]; then
            usage
        else
            echo "Listi delle app"
            # Logica per listare le app
        fi
        ;;
    rm)
        if [ $# -ne 1 ]; then
            usage
        else
            APPNAME=$1
            echo "Removing app: $APPNAME"
            # Logica per rimuovere l'app
        fi
        ;;
    add)
        if [ $# -lt 1 ]; then
            usage_app
        fi

        APPNAME=$1
        shift

        # Variabili opzionali
        SECRETS=0
        BUILD=""
        CONTAINER_NAME=""
        REMOTES=()

        # Parsing delle opzioni
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s|--secrets)
                    SECRETS=1
                    shift
                    ;;
                -b|--build)
                    BUILD=$2
                    shift 2
                    ;;
                --container-name)
                    CONTAINER_NAME=$2
                    shift 2
                    ;;
                -r|--remote)
                    REMOTES+=("$2")
                    shift 2
                    ;;
                *)
                    echo "Unknown option: $1"
                    usage
                    ;;
            esac
        done

        # Validazioni
        if [ -n "$BUILD" ] && [ -z "$CONTAINER_NAME" ]; then
            echo "Error: --container-name è richiesto quando usi --build"
            usage
        fi

        # Logica per l'aggiunta dell'app (da implementare !!!)
        echo "Aggiungo app: $APPNAME"
        if [ $SECRETS -eq 1 ]; then
            echo "Secrets enabled."
        fi
        if [ -n "$BUILD" ]; then
            echo "Build image: $BUILD"
        fi
        if [ -n "$CONTAINER_NAME" ]; then
            echo "Container name: $CONTAINER_NAME"
        fi
        if [ ${#REMOTES[@]} -gt 0 ]; then
            echo "Remote URLs: ${REMOTES[@]}"
        fi
        ;;
    *)
        usage
        ;;
esac
