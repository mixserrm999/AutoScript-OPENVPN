#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
    echo -e "Sorry, you need to run this as root!"
    exit 2
fi

read -n1 -r -p "Press any key to start ..."
clear

# Default Stunnel Value
COUNTRY="TH"
STATE="BANGKOK"
CITY="BANGKOK"
ORGANIZATION="SUPHANAT YOSBOONTHUNG"
ORGANIZATIONAL_UNIT="VPN"
COMMON_NAME="TBMODS"
EMAIL="mixserrm999@gmail.com"
PASSWORD="mixserrm999"

# Default SSH, OpenVPN, Stunnel Ports values
DEFAULT_OPENVPN_PORT="443"
DEFAULT_OPENVPN_SSL_PORT="443"

read -p "Enter OpenVPN Port: " -e -i $DEFAULT_OPENVPN_PORT OPENVPN_PORT
while [[ "$OPENVPN_PORT" == "" ]]
do
    read -p "Enter OpenVPN Port: " -e -i $DEFAULT_OPENVPN_PORT OPENVPN_PORT
done

read -p "Enter OpenVPN SSL Port: " -e -i $DEFAULT_OPENVPN_SSL_PORT OPENVPN_SSL_PORT
while [[ "$OPENVPN_SSL_PORT" == "" ]]
do
    read -p "Enter OpenVPN SSL Port: " -e -i $DEFAULT_OPENVPN_SSL_PORT OPENVPN_SSL_PORT
done

apt-get -y update
apt-get -y install stunnel4 openssl

echo "cert = /etc/stunnel/stunnel.pem

[openvpn]
accept = $OPENVPN_SSL_PORT
connect = 127.0.0.1:$OPENVPN_PORT" > /etc/stunnel/stunnel.conf

openssl genrsa -out key.pem 2048 && openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -passin pass:$PASSWORD \
    -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

cat key.pem cert.pem > /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

echo "Successfully installed SSL over SSH & OpenVPN!"
