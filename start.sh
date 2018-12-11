#!/bin/sh
#set -e
if [ -n "$TRACKER_SERVER" ] ; then  
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
fi
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart
/usr/sbin/nginx -g 'daemon off;'