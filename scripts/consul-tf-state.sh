#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
REDB="\033[31m"
GREENB="\033[1;32m"
BOLD="\033[1m"

usage()
{
  printf "\nUsage: $0 <init|destroy>\n\n"
}

error_msg()
{
  printf "${REDB}[ERROR]${RESET} $*\n"
}

put_kv()
{
  printf "Configure kv ${BOLD}$1 ${RESET}\n";
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put $1 $2 > /dev/null || { error_msg "Inserimento nel kv fallito"; exit 1; }
}

if [[ -z $1 ]] ; then
	usage;
	exit;
fi;





if [[ ! -f ./env ]] ; then
  printf "File ./env non trovato;"
  exit 1;
fi;



CONSUL_CONTAINER_NAME=""
CONSUL_CONTAINER_IMAGE=""
CONSUL_VOLUME_NAME=""
CONSUL_HOST_PORT=""
DOCKER_HOST_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
CONSUL_ENDPOINT=""

source './env'

if [[ -z "${CONSUL_CONTAINER_IMAGE}" || -z "${CONSUL_CONTAINER_NAME}" || -z "${CONSUL_VOLUME_NAME}" || -z "${CONSUL_HOST_PORT}" ]] ; then
  printf "Una o più variabili d'ambiente nel file ./env non è stata valorizzata\n";
  exit 1;
fi;




create_consul_tf()
{
  printf "Creazione volume ${CONSUL_VOLUME_NAME}"
  docker volume create ${CONSUL_VOLUME_NAME} || { error_msg "Creazione volume fallita" ; exit 1; };
  docker build -f ./storage-tf-build/Dockerfile -t ${CONSUL_CONTAINER_IMAGE} ./storage-tf-build || { error_msg "Creazione build fallita" ; exit 1; }

  docker run -d \
    --name=${CONSUL_CONTAINER_NAME} \
    -p ${CONSUL_HOST_PORT}:8500 \
    -v ${CONSUL_VOLUME_NAME}:/consul/data \
    ${CONSUL_CONTAINER_IMAGE} || { error_msg "Avvio del container fallito" ; exit 1; }


  CONTAINER_STATUS=$(docker inspect --format '{{ .State.Status }}' ${CONSUL_CONTAINER_NAME})
  CONTAINER_START=$(docker inspect --format '{{ .State.StartedAt }}' ${CONSUL_CONTAINER_NAME})
  IP_ADDRESS_INTERNAL=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CONSUL_CONTAINER_NAME})
  printf "${GREENB}Consul Storage per Terraform State avviato${RESET}\n";
  printf "\t${BOLD}Started At:${RESET}\t ${CONTAINER_START}\n";
  printf "\t${BOLD}Status:${RESET}\t\t ${CONTAINER_STATUS}\n";
  printf "\t${BOLD}IP Container:${RESET}\t ${IP_ADDRESS_INTERNAL}\n";
  printf "\t${BOLD}IP External:${RESET}\t ${DOCKER_HOST_IP}\n";
  printf "\t${BOLD}Endpoint:${RESET}\t http://${DOCKER_HOST_IP}:${CONSUL_HOST_PORT}/\n";
  put_kv "infrastructure/consul-tf-service/endpoint/fqdn" "http://${DOCKER_HOST_IP}:${CONSUL_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/endpoint/docker-host" "${DOCKER_HOST_IP}"
  put_kv "infrastructure/consul-tf-service/endpoint/docker-port" "${CONSUL_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/container/host" "${IP_ADDRESS_INTERNAL}"
  put_kv "infrastructure/consul-tf-service/container/port" "${CONSUL_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/container/name" "${CONSUL_CONTAINER_NAME}"
  put_kv "infrastructure/consul-tf-service/container/image" "${CONSUL_CONTAINER_IMAGE}" 
  put_kv "infrastructure/consul-tf-service/container/consul_image" "hashicorp/consul:1.20" 
  put_kv "infrastructure/consul-tf-service/container/volume-data" "${CONSUL_VOLUME_NAME}"
}

destroy_consul_tf()
{
  printf "\n${BOLD}Se distruggi lo storage, terraform non potrà più recuperare lo stato delle risorse${RESET}\n";
  printf "${BOLD}Confermi ? [y/n] :${RESET} "
  read -p "" confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    printf "Fermo il container ${CONSUL_CONTAINER_NAME}\n";
    docker container stop ${CONSUL_CONTAINER_NAME} > /dev/null || { error_msg "Impossibile fermare il container ${CONSULT_CONTAINER_NAME}" ; exit 1; }
    printf "Rimuovo il container ${CONSUL_CONTAINER_NAME}\n";
    docker container rm ${CONSUL_CONTAINER_NAME} > /dev/null || { error_msg "Impossibile rimuovere il container ${CONSULT_CONTAINER_NAME}" ; exit 1; }
    printf "Rimuovo il volume ${CONSUL_VOLUME_NAME}\n";
    docker volume rm ${CONSUL_VOLUME_NAME} > /dev/null || { error_msg "Impossibile rimuovere il volume ${CONSUL_VOLUME_NAME}" ; exit 1; }
    printf "Rimuovo l'immagine ${CONSUL_CONTAINER_IMAGE}\n";
    docker image rm --force ${CONSUL_CONTAINER_IMAGE} > /dev/null || { error_msg "Impossibile rimuovere l'immagine ${CONSUL_CONTAINER_IMAGE}" ; exit 1; }
  fi;
}

case "$1" in 
  "init")
  create_consul_tf;
  ;;
  "destroy")
  destroy_consul_tf;
  ;;
  *)
  usage;
  exit 1;
  ;;
esac