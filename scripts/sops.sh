#!/bin/bash

usage() {
	printf "Usage: $0 <env> <action> <filename>\n";
    printf "action : encrypt , decrypt, edit, new\n"
}

if [[ -z $3 ]] ; then
	usage;
	exit;
fi;

if [[ ! -d ./env/$1 ]] ; then
	printf "Ambiente $1 inesistente\n";
	exit;
fi;

transit_key=""

SOPS_ENV=$1
ACTION=$2
FILENAME=$3
SOURCE_SOPS="./env/${SOPS_ENV}/secrets.ini"
export VAULT_SKIP_VERIFY=true
export EDITOR=vi
export VAULT_ADDR="https://192.168.1.220:28200"

source "./env/${SOPS_ENV}/secrets.ini"

if [[ $2 == "edit" ]] ; then
    if [[ ! -f ${FILENAME} ]] ; then
        printf "Filename ${FILENAME} inesistente\n";
        printf "Se vuoi creare un nuovo file, usa $0 $1 new ${FILENAME}\n";
        exit;
    fi;
    sops edit --hc-vault-transit ${VAULT_ADDR}/v1/transit/${transit_key} ${FILENAME}
fi;

if [[ $2 == "new" ]] ; then
    if [[ -f ${FILENAME} ]] ; then
        printf "Filename ${FILENAME} già esistente\n";
        printf "Se vuoi editare un file esistente, usa $0 $1 edit ${FILENAME}\n";
        exit;
    fi;
    printf "{}" > ${FILENAME};
    sops encrypt -i --hc-vault-transit ${VAULT_ADDR}/v1/transit/${transit_key} ${FILENAME}
    sops edit --hc-vault-transit ${VAULT_ADDR}/v1/transit/${transit_key} ${FILENAME}
fi;

# sops encrypt --hc-vault-transit https://192.168.1.220:28200/v1/transit/sops_kv/my_key server.json
#sops edit --hc-vault-transit ${transit_key} ${FILENAME}




