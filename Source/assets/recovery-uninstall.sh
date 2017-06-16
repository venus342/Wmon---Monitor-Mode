#!/system/bin/sh
# By Hashcode
PATH=/system/bin:/system/xbin

INSTALLPATH=$1
RECOVERY_DIR=etc/safestrap
LOGFILE=$INSTALLPATH/action-uninstall.log
BBX=$INSTALLPATH/busybox
SS_CONFIG=$INSTALLPATH/ss.config

chmod 755 $BBX
chmod 755 $INSTALLPATH/ss_function.sh

. $INSTALLPATH/ss_function.sh
readConfig

CURRENTSYS=`$BBX readlink $BLOCK_DIR/$BLOCK_SYSTEM`
# check for older symlink style fixboot
if [ "$?" -ne 0 ]; then
	CURRENTSYS=`$BBX readlink $BLOCK_DIR/system`
fi
echo "CURRENTSYS = $CURRENTSYS" >> $LOGFILE
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$BBX mkdir $DESTMOUNT
		$BBX chmod 755 $DESTMOUNT
	fi
	$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/$BLOCK_SYSTEM-orig $DESTMOUNT
	if [ "$?" -ne 0 ]; then
		$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/systemorig $DESTMOUNT
	fi
else
	DESTMOUNT=/system
	sync
	$BBX mount -o remount,rw $DESTMOUNT
fi

if [ -f "$DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin" ]; then
	$BBX mv -f $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
	$BBX chown 0.2000 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
	$BBX chmod 755 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
fi

if [ -d "$DESTMOUNT/$RECOVERY_DIR" ]; then
	$BBX rm -r $DESTMOUNT/$RECOVERY_DIR >> $LOGFILE
fi

sync

# determine our active system, and umount/remount accordingly
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	$BBX umount $DESTMOUNT >> $LOGFILE
	$BBX rmdir $DESTMOUNT
else
	$BBX mount -o ro,remount $DESTMOUNT >> $LOGFILE
fi

