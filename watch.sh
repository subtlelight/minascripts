#!bin/bash
ip4=$(curl -s 'http://ifconfig.me')
status=$(/usr/local/bin/mina client status | grep -e 'Local uptime' -e 'Sync status' -e 'Block height' -e 'Max observed block height' -e 'Max observed unvalidated block height' -e 'Next block will be produced in' -e 'External IP')
#sidecar=$(sudo journalctl -u mina-bp-stats-sidecar.service | tail -n 7 | grep Finished | awk '{print $1,$2,$3,$6,$9}')

echo "ip4: $ip4"
echo
echo "Status:"$'\n'$'\n'"$status"$'\n'$'\n'"Sidecar Stats:"$'\n'$'\n'"$sidecar"
echo
echo "Uptime service - sent : $(journalctl --user -u mina -S "today" | grep 'Sent block with state' | wc -l), failed: $(journalctl --user -u mina -S "today" | grep 'After 8 attempts, failed' | wc -l), Errors : $(journalctl --user -u mina -S "today" | grep 'uptime' | grep 'Error' | wc -l)"
