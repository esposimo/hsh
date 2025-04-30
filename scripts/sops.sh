#!/bin/bash

#usage() {
#	printf "Usage: $0 <env> <action> <filename>\n";
#    printf "action : encrypt , decrypt, edit, new\n"
#}
#
#if [[ -z $3 ]] ; then
#	usage;
#	exit;
#fi;

#if [[ ! -d ./env/$1 ]] ; then
#	printf "Ambiente $1 inesistente\n";
#	exit;
#fi;

# load env 
REAL_SCRIPT=$(readlink -f $0)
REAL_PATH=$(dirname ${REAL_SCRIPT})
ENV_FILE=${REAL_PATH}/env
source ${ENV_FILE}


# setting vault environment
export VAULT_ADDR=$(curl ${CONSUL_ENDPOINT}/v1/kv/infrastructure/vault/endpoint 2>/dev/null | jq -r '.[0].Value' | base64 --decode)
export VAULT_TOKEN=$(curl ${CONSUL_ENDPOINT}/v1/kv/infrastructure/vault/security/root-key 2>/dev/null | jq -r '.[0].Value' | base64 --decode)
export VAULT_SKIP_VERIFY=true
export EDITOR=vi


transit_mount=""
transit_key=""
keyvault=""

SOPS_ENV=$1
ACTION=$2
FILENAME=$3
SOURCE_SOPS="./env/${SOPS_ENV}/secrets.ini"

source ${SOURCE_SOPS}

if [[ -z $transit_mount ]] ; then
    printf "Variabile transit mount inesistente\n";
    exit;
fi;

if [[ -z $transit_key ]] ; then
    printf "Variabile transit key inesistente\n";
    exit;
fi;

if [[ -z $keyvault ]] ; then
    printf "Variabile con path del kv inesistente\n";
    exit;
fi;


sops_new_file()
{
    if [[ -f ${FILENAME} ]] ; then
        printf "Il file ${FILENAME} già esiste\n";
        exit;
    fi;
    jq -n --arg value "value" '{key: $value}' > ${FILENAME};
    sops encrypt -i --hc-vault-transit ${VAULT_ADDR}/v1/${transit_mount}/keys/${transit_key} ${FILENAME}
    sops edit --hc-vault-transit ${VAULT_ADDR}/v1/${transit_mount}/keys/${transit_key} ${FILENAME}
}

sops_edit_file()
{
    if [[ ! -f ${FILENAME} ]] ; then
        printf "Il file ${FILENAME} non esiste\n";
        exit;
    fi;
    sops edit --hc-vault-transit ${VAULT_ADDR}/v1/${transit_mount}/keys/${transit_key} ${FILENAME}
}

sops_decrypt_file()
{
    if [[ ! -f ${FILENAME} ]] ; then
        printf "Il file ${FILENAME} non esiste\n";
        exit;
    fi;
    sops -d --hc-vault-transit ${VAULT_ADDR}/v1/${transit_mount}/keys/${transit_key} ${FILENAME}
}

sops_encrypt_file()
{
    if [[ ! -f ${FILENAME} ]] ; then
        printf "Il file ${FILENAME} non esiste\n";
        exit;
    fi;
    sops encrypt --hc-vault-transit ${VAULT_ADDR}/v1/${transit_mount}/keys/${transit_key} ${FILENAME}
}
case "${ACTION}" in 
    "new")
     sops_new_file
     ;;
    "edit")
     sops_edit_file
     ;;
    "decrypt")
     sops_decrypt_file
     ;;
    "encrypt")
     sops_encrypt_file
     ;;
    *)
     echo "Non hai specificato una azione valida";
     ;;
esac