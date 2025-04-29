#!/bin/bash

usage() {
	printf "Usage: $0 <env> <action> <TF-COMMAND>\n";
}

if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

if [[ ! -d ./env/$1 ]] ; then
	printf "Ambiente $1 inesistente\n";
	exit;
fi;

source './env'

TF_ENV=$1
ACTION=$2
shift 2
TERRAFORM_COMMAND=$*


REMOTE_BACKEND_REFERENCE="./env/${TF_ENV}/remote_backend.json"

OTHER_VAR_FILES=""
for x in $(jq -r '.[]' ${REMOTE_BACKEND_REFERENCE}) ; do
	OTHER_VAR_FILES="${OTHER_VAR_FILES} -var-file=${x}"
done;

BACKEND_FILE="./env/${TF_ENV}/backend.tfvars"
TF_VAR_FILE="./env/${TF_ENV}/variables.tfvars"

set -x
terraform init -reconfigure -backend-config=${BACKEND_FILE}
terraform ${ACTION} -var-file=${TF_VAR_FILE} ${OTHER_VAR_FILES} ${TERRAFORM_COMMAND}



# sops ha bisogno di 
# export VAULT_ADDR="https://192.168.1.220:28500"
# export VAULT_SKIP_VERIFY=true
# encrypt => sops encrypt --hc-vault-transit https://192.168.1.220:28200/v1/transit/sops_kv/my_key server.json
# decrypt => sops decrypt simone.json
# io devo creare un file di configurazione json con sops, e in automatico quando lo salvo deve risultare già crittografato
# per farlo, devo usare uno script che si carica in automatico le configurazioni e mi va in modalità editing
# una volta che ho salvato, posso decriptare il file o editarlo in automatico perchè sops all'interno del file ha già le informazioni per decriptare
# 
# lato terraform invece, devo solo prenddere i valori del file decriptato con sops, e metterli in "chiaro" in un kv dedicato
