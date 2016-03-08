#!/bin/bash
if [ $# -ne 3 ]
then
  echo "Usage: spawn_netconf_container <image-name> <container-name> <yang-filename>"
  exit 0
fi

IMAGE_NAME=$1
CONTAINER_NAME=$2
YANG_FILE_NAME=$3

#Remove any existing
sudo docker rm -f $CONTAINER_NAME &>/dev/null

DOCKER_ID='sudo docker run --name $CONTAINER_NAME -dit $IMAGE_NAME /bin/bash'

echo "Spawned container with IP 'sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER_NAME'"

####### Start NETCONF server with custom YANG model
sudo docker cp base_datastore.xml ${CONTAINER_NAME}:/usr/local/etc/netopeer/cfgnetopeer/datastore.xml
sudo docker cp ${YANG_FILE_NAME}.yang ${CONTAINER_NAME}:/root/${YANG_FILE_NAME}.yang
sudo docker exec $CONTAINER_NAME pyang -f yin /root/${YANG_FILE_NAME}.yang -o /root/${YANG_FILE_NAME}.yin
sudo docker exec $CONTAINER_NAME netopeer-manager add --name ${YANG_FILE_NAME} --model ${YANG_FILE_NAME}.yin --datastore /usr/local/etc/netopeer/cfgnetopeer/${YANG_FILE_NAME}.xml
sudo docker exec $CONTAINER_NAME netopeer-server -d
