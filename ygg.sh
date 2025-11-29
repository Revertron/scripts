#!/usr/bin/bash
apt install dirmngr -y
mkdir -p /usr/local/apt-keys
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export 1C5162E133015D81A811239D1840CDAC6011C5EA | sudo tee /usr/local/apt-keys/yggdrasil-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/local/apt-keys/yggdrasil-keyring.gpg] http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' > /etc/apt/sources.list.d/yggdrasil.list

apt update && apt install yggdrasil -y

if [ ! -f /etc/yggdrasil/yggdrasil.conf ];
then
  echo "Generating initial configuration file /etc/yggdrasil/yggdrasil.conf"
  mkdir -p /etc/yggdrasil
  /usr/sbin/yggdrasil -genconf > /etc/yggdrasil/yggdrasil.conf
  # Add some peers
  sed -i 's|  Peers: \[\]|  Peers: [ "tcp://77.247.225.234:7743", "tcp://45.95.38.230:7743", "tcp://31.57.241.91:7743" ]|' /etc/yggdrasil/yggdrasil.conf

  chown root:yggdrasil /etc/yggdrasil/yggdrasil.conf
  chmod 640 /etc/yggdrasil/yggdrasil.conf
fi

systemctl restart yggdrasil
