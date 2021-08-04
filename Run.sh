#!/bin/bash

#
# Keep alive for a while, hopefully overlapping with previous to keep remote system accessible.
#
( caffeinate -i -m -s -t 60 || true ) & 

#
# Send up-to-date info about the system.
#
( set -x ; 
  date ;
  uptime ;
  df -h ) > /Users/NadineClark/Scripts/info.txt
  
curl -X POST --data-binary @/Users/NadineClark/Scripts/info.txt http://halclark.ca/NadinesMBPUpdate

RSYNC="rsync"
if [ -f '/usr/local/bin/rsync' ] ; then
    # Homebrew version, which is much newer than the system rsync.
    # Rsync's newer than v3.0 support incremental recursion to reduce memory consumption.
    # Note: install using homebrew via `/usr/local/bin/brew install rsync'
    RSYNC='/usr/local/bin/rsync'
fi

caffeinate -i -m \
  $RSYNC \
        -rtvPL \
        --rsync-path="nice -n 19 /usr/bin/rsync" \
        --size-only \
        --inplace \
        --bwlimit=150 \
        --include='*txt'  --include='*TXT' \
        --include='*JPG'  --include='*MOV' \
        --include='*jpg'  --include='*mov' \
        --include='*PNG'  --include='*MP4' \
        --include='*png'  --include='*mp4' \
        --include='*HEIC' --include='*heic' \
        --include='*/' \
        --exclude='*' \
        '/Users/NadineClark/Scripts/info.txt' \
        root@www.halclark.ca:'/root/NadinesMBP/'

rm /Users/NadineClark/Scripts/info.txt
