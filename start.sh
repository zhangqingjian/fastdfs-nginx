#!/bin/sh
#set -e  insert multiply tracker_server
## sed '2i 111\n222\n333' sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}\n tracker_server=${TRACKER_SERVER2} |g" /etc/fdfs/storage.conf
if [ -n "$TRACKER_SERVER" ] ; then  
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
fi
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart
/usr/sbin/nginx -g 'daemon off;'
