#!/bin/bash

echo
echo "deb [trusted=yes] http://packages.o1test.net $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/mina.list
sudo apt-get update && sudo apt-get install -y mina-generate-keypair=1.3.0-9b0369c libjemalloc-dev
#echo "set MINA VERSION https://docs.minaprotocol.com/en/getting-started "
#read -p "mina-mainnet=: " minaversion
echo
echo
echo
echo "SET public key key/my-wallet.pub if not set NEW KEYS WILL BE GENERATED!!! "
read -p "key/my-wallet.pub : " walletpubkey

if [ -z "$walletpubkey" ]; then
  echo '$walletpubkey is not set GENERATING NEW '
  mkdir ~/keys
  chmod 700 ~/keys
  mina-generate-keypair --privkey-path ~/keys/my-wallet
  chmod 600 ~/keys/my-wallet
  else
   echo
   echo "SET private key ~/keys/my-wallet https://docs.minaprotocol.com/en/using-mina/keypair "
   read -p "~/keys/my-wallet: " walletkey
fi
echo
echo
echo "set MINA KEY PASSWORD (AGAIN)"
   read -p "MINA KEY PASSWORD AGAIN: " minakeypass
echo
echo
echo "set COINBASE RECEIVER ADDRESS if not set NEW KEYS WILL BE GENERATED!!!"
read -p "COINBASE RECEIVER ADDRESS: " coinbasereceiver
if [ -z "$coinbasereceiver" ]; then
  echo 'coinbasereceiver is not set'
  mkdir ~/coinrec
  chmod 700 ~/coinrec
  mina-generate-keypair --privkey-path ~/coinrec/my-wallet
  chmod 600 ~/coinrec/my-wallet
  coinbasereceiver=$(<~/coinrec/my-wallet.pub)
  echo "$coinbasereceiver"
fi

username=$(whoami)

YELLOW="\033[33m"
GREEN="\033[32m"

echo "---------------"
echo -e "$YELLOW Downloading libraries.\033[0m"
echo "---------------"
echo
cd
mkdir -p libs
cd libs 
wget http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/j/jemalloc/libjemalloc1_3.6.0-11_amd64.deb
wget http://mirrors.edge.kernel.org/ubuntu/pool/main/p/procps/libprocps6_3.3.12-3ubuntu1_amd64.deb

echo "---------------"
echo -e "$YELLOW Installing libraries.\033[0m"
echo "---------------"

sudo dpkg -i *.deb
cd

echo "---------------"
echo -e "$YELLOW Deleting all packages.\033[0m"
echo "---------------"

rm -rf libs

echo "---------------"
echo -e "$GREEN Libraries successfully installed.\033[0m"
echo "---------------"




sudo echo "deb [trusted=yes] http://packages.o1test.net stretch stable" | sudo tee /etc/apt/sources.list.d/mina.list
#sudo apt-get update && sudo apt-get install -y mina-mainnet="$minaversion"
sudo apt-get update && sudo apt-get install -y mina-mainnet

echo 'CODA_PRIVKEY_PASS="'"$minakeypass"'"
UPTIME_PRIVKEY_PASS="'"$minakeypass"'"
MINA_PRIVKEY_PASS="'"$minakeypass"'"
LOG_LEVEL=Info
FILE_LOG_LEVEL=Debug
EXTRA_FLAGS=" --block-producer-key /home/'"${username}"'/keys/my-wallet --uptime-submitter-key /home/'"${username}"'/keys/my-wallet --uptime-url https://uptime-backend.minaprotocol.com/v1/submit --limited-graphql-port 3095 --minimum-block-reward 684 --coinbase-receiver '"$coinbasereceiver"' "' > .mina-env

if [ -z "$walletpubkey" ]; then
      echo
   else
     mkdir ~/keys
     chmod 700 ~/keys
     echo "$walletkey" > ~/keys/my-wallet
     chmod 600 ~/keys/my-wallet
     echo "$walletpubkey" > ~/keys/my-wallet.pub
fi

systemctl --user daemon-reload && systemctl --user start mina && systemctl --user enable mina && sudo loginctl enable-linger

sudo apt-get install -y mina-bp-stats-sidecar
sudo bash -c "echo ' {
  \"uploadURL\": \"https://us-central1-mina-mainnet-303900.cloudfunctions.net/block-producer-stats-ingest/?token=72941420a9595e1f4006e2f3565881b5\",
  \"nodeURL\": \"http://127.0.0.1:3095\"
} ' > /etc/mina-sidecar.json"

sudo systemctl enable mina-bp-stats-sidecar && sudo systemctl daemon-reload && sudo service mina-bp-stats-sidecar restart
echo
echo
echo
systemctl --no-pager --user status mina 
echo
echo
echo
sudo service mina-bp-stats-sidecar status | cat
echo
echo USEFULL COMMANDS:
echo
echo 'systemctl --user status mina'
echo
echo 'service mina-bp-stats-sidecar status'
echo
echo 'watch -n 10 mina client status'
echo
echo 'journalctl --user-unit mina -n 1000 -f'
echo
echo 'sudo journalctl -o cat -f -u mina-bp-stats-sidecar.service'

