#!/bin/bash

echo
#echo "set MINA VERSION https://docs.minaprotocol.com/en/getting-started "
#read -p "mina-mainnet=: " minaversion
echo "set public key key/my-wallet.pub if not set NEW KEYS WILL BE GENERATED!!! "
read -p "key/my-wallet: " walletpubkey

if [ -z "$walletpubkey" ]; then
  echo '$walletpubkey is not set GENERATING NEW '
  echo "deb [trusted=yes] http://packages.o1test.net $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/mina.list
  sudo apt-get update && sudo apt-get install mina-generate-keypair=1.3.0-9b0369c libjemalloc-dev
  mkdir ~/keys
  chmod 700 ~/keys
  mina-generate-keypair --privkey-path ~/key/my-wallet
  chmod 600 ~/key/my-wallet
  else
   echo
   echo "set private key ~/key/my-wallet https://docs.minaprotocol.com/en/using-mina/keypair "
   read -p "~/key/my-wallet: " walletkey
fi
echo
echo
echo "set MINA KEY PASSWORD AGAIN"
   read -p "MINA KEY PASSWORD AGAIN: " minakeypass
echo
echo
echo "set COINBASE RECEIVER ADDRESS "
read -p "COINBASE RECEIVER ADDRESS: " coinbasereceiver
if [ -z "$coinbasereceiver" ]; then
  echo 'coinbasereceiver is not set'
  echo "deb [trusted=yes] http://packages.o1test.net $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/mina.list
  sudo apt-get update && sudo apt-get install mina-generate-keypair=1.3.0-9b0369c libjemalloc-dev
  mkdir ~/coinrec
  chmod 700 ~/coinrec
  mina-generate-keypair --privkey-path ~/coinrec/my-wallet
  chmod 600 ~/coinrec/my-wallet
  coinbasereceiver="cat keys/my-wallet.pub"
  else
   echo
   echo "set COINBASE RECEIVER ADDRESS"
   read -p "COINBASE RECEIVER ADDRESS: " coinbasereceiver
   echo
fi

username="whoami"

sudo echo "deb [trusted=yes] http://packages.o1test.net stretch stable" | sudo tee /etc/apt/sources.list.d/mina.list
#sudo apt-get update && sudo apt-get install -y mina-mainnet="$minaversion"
sudo apt-get update && sudo apt-get install -y mina-mainnet

echo 'CODA_PRIVKEY_PASS="'"$minakeypass"'"
UPTIME_PRIVKEY_PASS="'"$minakeypass"'"
MINA_PRIVKEY_PASS="'"$minakeypass"'"
LOG_LEVEL=Info
FILE_LOG_LEVEL=Debug
EXTRA_FLAGS=" --block-producer-key /home/minadmin/keys/my-wallet --uptime-submitter-key /home/minadmin/keys/my-wallet --uptime-url https://uptime-backend.minaprotocol.com/v1/submit --limited-graphql-port 3095 --minimum-block-reward 684 --coinbase-receiver '"$coinbasereceiver"' "' > .mina-env

if [ -z "$walletpubkey" ]; then
      echo
   else
     mkdir ~/keys
     chmod 700 ~/keys
     echo "$walletkey" > ~/keys/my-wallet
     chmod 600 ~/keys/my-wallet
     echo "$walletpubkey" > ~/keys/my-wallet.pub
fi

sudo systemctl daemon-reload && systemctl --user daemon-reload && systemctl --user stop mina && systemctl --user restart mina

sudo apt-get install -y mina-bp-stats-sidecar
sudo bash -c "echo ' {
  \"uploadURL\": \"https://us-central1-mina-mainnet-303900.cloudfunctions.net/block-producer-stats-ingest/?token=72941420a9595e1f4006e2f3565881b5\",
  \"nodeURL\": \"http://127.0.0.1:3095\"
} ' > /etc/mina-sidecar.json"

sudo systemctl daemon-reload && systemctl --user daemon-reload && sudo service mina-bp-stats-sidecar restart
echo
echo
echo
systemctl --no-pager --user status mina 
echo
echo
echo
sudo service mina-bp-stats-sidecar status | cat
echo
echo
echo
echo 'watch -n 10 mina client status'
echo 'journalctl --user-unit mina -n 1000 -f'
echo 'sudo journalctl -o cat -f -u mina-bp-stats-sidecar.service'

