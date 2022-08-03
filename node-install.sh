#!/bin/bash

echo
#echo "set MINA VERSION https://docs.minaprotocol.com/en/getting-started "
#read -p "mina-mainnet=: " minaversion
echo
echo "set MINA KEY PASSWORD"
read -p "MINA KEY PASSWORD: " minakeypass
echo
echo "set COINBASE RECEIVER ADDRESS"
read -p "COINBASE RECEIVER ADDRESS: " coinbasereceiver
echo
echo "set private key ~/key/my-wallet https://docs.minaprotocol.com/en/using-mina/keypair "
read -p "~/key/my-wallet: " walletkey
echo
echo "set public key key/my-wallet.pub https://docs.minaprotocol.com/en/using-mina/keypair "
read -p "key/my-wallet: " walletpubkey
echo
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

mkdir ~/key
chmod 700 ~/key
echo "$walletkey" > ~/keys/my-wallet
chmod 600 ~/key/my-wallet
echo "$walletpubkey" > ~/keys/my-wallet.pub

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

