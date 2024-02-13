#!/bin/bash

# sh install.sh download_url nodes_ip cloud_name ssh_username

# install azul zulu jdk repo
sudo apt update
sudo apt install gnupg ca-certificates curl -y
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list

sudo apt update

sudo apt install zulu8-ca-jre-headless -y

MIGRATORYDATA_RELEASE=$1
NODES=$2
CLOUD_NAME=$3
SSH_USERNAME=$4

###############################################################################
# Set ulimits
###############################################################################


###############################################################################
# Download and install the software.
###############################################################################
echo "Downloading package $MIGRATORYDATA_RELEASE"
wget -q "$MIGRATORYDATA_RELEASE"

echo "Installing deb package"
sudo dpkg -i *.deb

sudo systemctl enable migratorydata


MIGRATORYDATA_HOME="/etc/migratorydata"

case "$CLOUD_NAME" in

  'AWS')
    NODEIP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
    ;;

  'Azure')
    NODEIP="$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")"
    ;;

  'GCP')
    NODEIP="$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google")"
    ;;

  *)
    echo "Invalid Cloud Name"
    exit 1
    ;;
esac

echo "Finalizing configuration..."

cp -f /home/$SSH_USERNAME/migratorydata.conf "$MIGRATORYDATA_HOME/migratorydata.conf"

# authorization
[ -f "/home/$SSH_USERNAME/authorization-jwt-configuration.properties" ] && cp -f "/home/$SSH_USERNAME/authorization-jwt-configuration.properties" /etc/migratorydata/addons/authorization-jwt/configuration.properties
[ -f "/home/$SSH_USERNAME/extensions/authorization.jar" ] && cp -f "/home/$SSH_USERNAME/extensions/authorization.jar" /usr/share/migratorydata/extensions/authorization.jar
# audit
[ -f "/home/$SSH_USERNAME/audit-log4j-log4j2.xml" ] && cp -f "/home/$SSH_USERNAME/audit-log4j-log4j2.xml" /etc/migratorydata/addons/audit-log4j/log4j2.xml
[ -f "/home/$SSH_USERNAME/extensions/audit.jar" ] && cp -f "/home/$SSH_USERNAME/extensions/audit.jar" /usr/share/migratorydata/extensions/audit.jar
# kafka
[ -f "/home/$SSH_USERNAME/kafka-consumer.properties" ] && cp -f "/home/$SSH_USERNAME/kafka-consumer.properties" /etc/migratorydata/addons/kafka/consumer.properties
[ -f "/home/$SSH_USERNAME/kafka-producer.properties" ] && cp -f "/home/$SSH_USERNAME/kafka-producer.properties" /etc/migratorydata/addons/kafka/producer.properties

# update server configuration file and copy to path
echo "\nClusterMemberListen=$NODEIP:8801" | sudo tee -a "$MIGRATORYDATA_HOME/migratorydata.conf"
echo "\nClusterMembers=$NODES" | sudo tee -a "$MIGRATORYDATA_HOME/migratorydata.conf"

cp -f /home/$SSH_USERNAME/migratorydata /etc/default/migratorydata

echo "Restart the server..."
sudo systemctl restart migratorydata