#!/bin/bash

usage()
{
  printf "\nUsage: $0 <init|destroy>\n\n"
}


if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

source './env'


if [[ $1 == "init" ]] ; then

  docker volume create ${CONSUL_VOLUME_NAME};
  docker build -f ./storage-tf-build/Dockerfile -t ${CONSUL_CONTAINER_IMAGE} ./storage-tf-build

  docker run -d \
    --name=${CONSUL_CONTAINER_NAME} \
    -p ${CONSUL_HOST_PORT}:8500 \
    -v ${CONSUL_VOLUME_NAME}:/consul/data \
    ${CONSUL_CONTAINER_IMAGE} \


  CONTAINER_STATUS=$(docker inspect --format '{{ .State.Status }}' ${CONSUL_CONTAINER_NAME})
  CONTAINER_START=$(docker inspect --format '{{ .State.StartedAt }}' ${CONSUL_CONTAINER_NAME})
  IP_ADDRESS_INTERNAL=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CONSUL_CONTAINER_NAME})
  printf "Consul Storage per Terraform State avviato\n";
  printf "\tStarted At:\t ${CONTAINER_START}\n";
  printf "\tStatus:\t\t ${CONTAINER_STATUS}\n";
  printf "\tIP Container:\t ${IP_ADDRESS_INTERNAL}\n";
  printf "\tIP External:\t ${DOCKER_HOST_IP}\n";
  printf "\tEndpoint:\t http://${DOCKER_HOST_IP}:${CONSUL_HOST_PORT}/\n";
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/endpoint/fqdn http://${DOCKER_HOST_IP}:${CONSUL_HOST_PORT} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/endpoint/docker-host ${DOCKER_HOST_IP} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/endpoint/docker-port ${CONSUL_HOST_PORT} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/host ${IP_ADDRESS_INTERNAL} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/port ${CONSUL_HOST_PORT} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/name ${CONSUL_CONTAINER_NAME} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/image ${CONSUL_CONTAINER_IMAGE} >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/consul_image hashicorp/consul:1.20 >/dev/null
  docker exec -it ${CONSUL_CONTAINER_NAME} consul kv put infrastructure/consul-tf-service/container/volume-data ${CONSUL_VOLUME_NAME} >/dev/null
  exit;
fi;

if [[ $1 == "destroy" ]] ; then
  printf "\nSe distruggi lo storage, terraform non potrà più recuperare lo stato delle risorse\n";
  read -p "Confermi ? [y/n] " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker container stop ${CONSUL_CONTAINER_NAME} > /dev/null;
    docker container rm ${CONSUL_CONTAINER_NAME} > /dev/null;
    docker volume rm ${CONSUL_VOLUME_NAME} > /dev/null;
    docker image rm --force ${CONSUL_CONTAINER_IMAGE};
  fi;
  exit;
fi;