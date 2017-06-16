#!/system/bin/sh
# By Hashcode
PATH=/system/bin:/system/xbin:/sbin

INSTALLPATH=$1
RECOVERY_DIR=etc/safestrap
LOGFILE=$INSTALLPATH/action-check.log
BBX=$INSTALLPATH/busybox
SS_CONFIG=$INSTALLPATH/ss.config
vers=0
alt_boot_mode=0

chmod 755 $BBX
chmod 755 $INSTALLPATH/ss_function.sh

. $INSTALLPATH/ss_function.sh
readConfig

CURRENTSYS=`$BBX readlink $BLOCK_DIR/$BLOCK_SYSTEM`
# check for older symlink style fixboot
if [ "$?" -ne 0 ]; then
	CURRENTSYS=`$BBX readlink $BLOCK_DIR/system`
fi
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	# alt-system, needs to mount original /system
	alt_boot_mode=1
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$BBX mkdir $DESTMOUNT
	fi
	$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/$BLOCK_SYSTEM-orig $DESTMOUNT
	if [ "$?" -ne 0 ]; then
		$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/systemorig $DESTMOUNT
	fi
else
	DESTMOUNT=/system
fi

if [ -f "$DESTMOUNT/$RECOVERY_DIR/flags/version" ]; then
	vers=`$BBX cat $DESTMOUNT/$RECOVERY_DIR/flags/version`
fi

if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	$BBX umount $DESTMOUNT
fi
echo "$vers:$alt_boot_mode"

