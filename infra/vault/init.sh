#!/bin/bash


terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform apply -var-file="./config/variables.tfvars"

source '../../scripts/env'

CORE_VAULT_CONTAINER_NAME=$(terraform output -raw core_vault_container_name)
CORE_VAULT_ENDPOINT=$(terraform output -raw core_vault_host_endpoint)
TEMP_SPOOL_VAULT=$(mktemp)

printf "Inizializzo il vault\n";
sleep 3;

docker cp ./config/init-vault.sh ${CORE_VAULT_CONTAINER_NAME}:/tmp/init-vault.sh > /dev/null
docker exec -it ${CORE_VAULT_CONTAINER_NAME} /tmp/init-vault.sh > /dev/null
docker cp ${CORE_VAULT_CONTAINER_NAME}:/tmp/spool_x_docker.log ${TEMP_SPOOL_VAULT} > /dev/null
docker exec -it ${CORE_VAULT_CONTAINER_NAME} rm /tmp/init-vault.sh /tmp/spool_x_docker.log > /dev/null

ROOT_KEY=$(cat ${TEMP_SPOOL_VAULT} | jq -r '.ROOT_KEY')
UNSEAL_KEY=$(cat ${TEMP_SPOOL_VAULT} | jq -r '.UNSEAL_KEY')

printf "Inserisco le chiavi di root-key e unseal-key sul consul di progetto : ${CONSUL_ENDPOINT}\n";
docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/vault/security/root-key ${ROOT_KEY} >/dev/null
docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/vault/security/unseal-key ${UNSEAL_KEY} > /dev/null
docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/vault/endpoint ${CORE_VAULT_ENDPOINT} > /dev/null
printf "KV path: infrastructure/vault/security/root-key\n";
printf "KV path: infrastructure/vault/security/unseal-key\n";
printf "KV path: infrastructure/vault/endpoint\n";

rm -f ${TEMP_SPOOL_VAULT}