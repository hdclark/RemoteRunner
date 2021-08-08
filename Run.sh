#!/bin/bash

if [ -z "$(hostname | grep -i Nadines-MBP)" ] ; then
    exit 1
fi

# Keep alive for a while, hopefully overlapping with previous to keep remote system accessible.
#
( caffeinate -i -m -s -t 60 || true ) & 


# Ensure the port-forwarding services are enabled and running.
#
# com.halclark.autosshportfwd
# com.halclark.syncphotos
#
#launchctl unload  /Library/LaunchAgents/com.halclark.autosshportfwd.plist 
#launchctl load -w /Library/LaunchAgents/com.halclark.autosshportfwd.plist 
#sudo launchctl enable system/com.halclark.autosshportfwd
#sudo launchctl enable user/com.halclark.syncphotos
#sudo launchctl print system/com.halclark.autosshportfwd
#sudo launchctl print user/com.halclark.syncphotos
#sudo launchctl kickstart -k system/com.openssh.sshd

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

# Sync photos.
caffeinate -i -m \
  $RSYNC \
        -rtvPL \
        --rsync-path="nice -n 19 /usr/bin/rsync" \
        --inplace \
        --ignore-existing \
        --size-only \
        --bwlimit=150 \
        --include='*JPG'  --include='*MOV' \
        --include='*jpg'  --include='*mov' \
        --include='*PNG'  --include='*MP4' \
        --include='*png'  --include='*mp4' \
        --include='*HEIC' --include='*heic' \
        --include='*/' \
        --exclude='*' \
        -e 'ssh -t -A root@www.halclark.ca  "ssh -t -p 2322 sarah@localhost" ' \
        '/Volumes/NadinesPhotos/Photos Library.photoslibrary/Masters/2021/' \
        :'/media/sarah/8T_drive_C/NadinesPhotos/Photos\\ Library.photoslibrary/Masters/2021/'

#        '/Volumes/NadinesPhotos/' \
#        :'/media/sarah/8T_drive_C/NadinesPhotos/'

