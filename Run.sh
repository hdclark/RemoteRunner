#!/bin/bash

# Keep alive for a while.
( caffeinate -i -m -s -t 60 || true ) & 

echo OK

# Send up-to-date info about the system.
curl -X POST --data-binary @<(date ; echo OK ; df -h) http://halclark.ca/NadinesMBPUpdate
