#!/system/bin/sh
# By Hashcode
PATH=/system/bin:/system/xbin

INSTALLPATH=$1
RECOVERY_DIR=etc/safestrap
LOGFILE=$INSTALLPATH/action-install.log
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
if [ -d $INSTALLPATH/install-files ]; then
	rm -r $INSTALLPATH/install-files >> $LOGFILE
fi

$BBX unzip $INSTALLPATH/install-files.zip  -d $INSTALLPATH >> $LOGFILE
if [ ! -d $INSTALLPATH/install-files ]; then
	echo 'ERR: Zip file didnt extract correctly.  Installation aborted.' >> $LOGFILE
	exit 1
fi

# determine our active system, and mount/remount accordingly
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$BBX mkdir $DESTMOUNT
		$BBX chmod 755 $DESTMOUNT
	fi
	$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/$BLOCK_SYSTEM-orig $DESTMOUNT >> $LOGFILE
	if [ "$?" -ne 0 ]; then
		$BBX mount -t $SYSTEM_FSTYPE $BLOCK_DIR/systemorig $DESTMOUNT
	fi
else
	DESTMOUNT=/system
	sync
	$BBX mount -o remount,rw $DESTMOUNT >> $LOGFILE
fi

# check for a $HIJACK_LOC/$HIJACK_BIN.bin file and its not there, make a copy
if [ ! -f "$DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin" ]; then
	$BBX cp $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin >> $LOGFILE
	$BBX chown 0.2000 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin >> $LOGFILE
	$BBX chmod 755 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN.bin >> $LOGFILE
fi
$BBX rm $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
$BBX cp -f $INSTALLPATH/install-files/$HIJACK_LOC/$HIJACK_BIN $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
$BBX chown 0.2000 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE
$BBX chmod 755 $DESTMOUNT/$HIJACK_LOC/$HIJACK_BIN >> $LOGFILE

# delete any existing /system/etc/safestrap dir
if [ -d "$DESTMOUNT/$RECOVERY_DIR" ]; then
	$BBX rm -rf $DESTMOUNT/$RECOVERY_DIR >> $LOGFILE
fi
# extract the new dirs to /system
$BBX cp -R $INSTALLPATH/install-files/$RECOVERY_DIR $DESTMOUNT/etc >> $LOGFILE
$BBX chown 0.2000 $DESTMOUNT/$RECOVERY_DIR/* >> $LOGFILE
$BBX chmod 755 $DESTMOUNT/$RECOVERY_DIR/* >> $LOGFILE

# determine our active system, and umount/remount accordingly
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	# if we're in 2nd-system then re-enable safe boot
	$BBX touch $DESTMOUNT/$RECOVERY_DIR/flags/alt_system_mode >> $LOGFILE

	$BBX umount $DESTMOUNT >> $LOGFILE
	$BBX rmdir $DESTMOUNT >> $LOGFILE
else
	$BBX mount -o ro,remount $DESTMOUNT >> $LOGFILE
fi

