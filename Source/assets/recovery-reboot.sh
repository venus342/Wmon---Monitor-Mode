#!/system/bin/sh
# By Hashcode
PATH=/system/bin:/system/xbin

INSTALLPATH=$1
BBX=$INSTALLPATH/busybox
SS_CONFIG=$INSTALLPATH/ss.config

chmod 755 $BBX
chmod 755 $INSTALLPATH/ss_function.sh

. $INSTALLPATH/ss_function.sh
readConfig

$BBX echo 1 > /data/$SS_RECOVERY_FILE
$BBX sync


