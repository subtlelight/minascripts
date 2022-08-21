#!bin/bash

echo "Uptime service - sent : $(journalctl --user -u mina -S "today" | grep 'Sent block with state' | wc -l), failed: $(journalctl --user -u mina -S "today" | grep 'After 8 attempts, failed' | wc -l), Errors : $(journalctl --user -u mina -S "today" | grep 'uptime' | grep 'Error' | wc -l)"