#!/usr/bin/bash
apt install dirmngr
mkdir -p /usr/local/apt-keys
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export BC1BF63BD10B8F1A | tee /usr/local/apt-keys/yggdrasil-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/local/apt-keys/yggdrasil-keyring.gpg] http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' > /etc/apt/sources.list.d/yggdrasil.list

apt update && apt install yggdrasil

# Add some peers
sed -i 's|  Peers: \[\]|  Peers: [ "tcp://77.247.225.234:7743", "tcp://185.193.159.245:7743" ]|' /etc/yggdrasil/yggdrasil.conf
systemctl restart yggdrasil