BLOCK_DIR=/dev/block
SYS2_MNT=/s2
USER2_MNT=/u2
DATAMEDIA_MNT=/datamedia
SS_MNT=/ss
SS_RECOVERY_FILE=.recovery_mode

# read ss.config
readConfig() {
	BLOCK_SYSTEM=$($BBX fgrep "SYSTEM=" $SS_CONFIG | $BBX sed 's/SYSTEM=//')
	SYSTEM_FSTYPE=$($BBX fgrep "SYSTEM_FSTYPE=" $SS_CONFIG | $BBX sed 's/SYSTEM_FSTYPE=//')
	BLOCK_USERDATA=$($BBX fgrep "USERDATA=" $SS_CONFIG | $BBX sed 's/USERDATA=//')
	USERDATA_FSTYPE=$($BBX fgrep "USERDATA_FSTYPE=" $SS_CONFIG | $BBX sed 's/USERDATA_FSTYPE=//')
	BLOCK_CACHE=$($BBX fgrep "CACHE=" $SS_CONFIG | $BBX sed 's/CACHE=//')
	BLOCK_BOOT=$($BBX fgrep "BOOT=" $SS_CONFIG | $BBX sed 's/BOOT=//')
	SS_PART=$($BBX fgrep "SS_PART=" $SS_CONFIG | $BBX sed 's/SS_PART=//')
	SS_FSTYPE=$($BBX fgrep "SS_FSTYPE=" $SS_CONFIG | $BBX sed 's/SS_FSTYPE=//')
	SS_DIR=$($BBX fgrep "SS_DIR=" $SS_CONFIG | $BBX sed 's/SS_DIR=//')
	HIJACK_BIN=$($BBX fgrep "HIJACK_BIN=" $SS_CONFIG | $BBX sed 's/HIJACK_BIN=//')
	HIJACK_LOC=$($BBX fgrep "HIJACK_LOC=" $SS_CONFIG | $BBX sed 's/HIJACK_LOC=//')
	BOOTMODE=$(getprop $($BBX fgrep "BOOTMODE_PROP=" $SS_CONFIG | $BBX sed 's/BOOTMODE_PROP=//'))
	CHECK_BOOTMODE="$($BBX fgrep "CHECK_BOOTMODE=" $SS_CONFIG | $BBX sed 's/CHECK_BOOTMODE=//')"
	DEVICE=$(getprop $($BBX fgrep "DEVICE_PROP=" $SS_CONFIG | $BBX sed 's/DEVICE_PROP=//'))
	CHARGER_MODE=$($BBX cat $($BBX fgrep "CHARGER_MODE_SYSFS=" $SS_CONFIG | $BBX sed 's/CHARGER_MODE_SYSFS=//'))
	POWERUP_REASON_TEMP="$($BBX fgrep "CHECK_POWERUP_REASON=" $SS_CONFIG | $BBX sed 's/CHECK_POWERUP_REASON=//')"
	POWERUP_REASON=$(eval $POWERUP_REASON_TEMP 2>/dev/null)
	POWERUP_REASON_CHARGER=$($BBX fgrep "POWERUP_REASON_CHARGER=" $SS_CONFIG | $BBX sed 's/POWERUP_REASON_CHARGER=//')
	BACKLIGHT_BRIGHTNESS_PATH=$($BBX fgrep "BACKLIGHT_BRIGHTNESS_PATH=" $SS_CONFIG | $BBX sed 's/BACKLIGHT_BRIGHTNESS_PATH=//')
	BACKLIGHT_BRIGHTNESS_VALUE=$($BBX fgrep "BACKLIGHT_BRIGHTNESS_VALUE=" $SS_CONFIG | $BBX sed 's/BACKLIGHT_BRIGHTNESS_VALUE=//')
	TASKSET_CPUS=$($BBX fgrep "TASKSET_CPUS=" $SS_CONFIG | $BBX sed 's/TASKSET_CPUS=//')
	SS_USE_DATAMEDIA=$($BBX fgrep "SS_USE_DATAMEDIA=" $SS_CONFIG | $BBX sed 's/SS_USE_DATAMEDIA=//')
	DEBUG_MODE=$($BBX fgrep "DEBUG_MODE=" $SS_CONFIG | $BBX sed 's/DEBUG_MODE=//')
}

# print ss.config to kmsg
dumpConfig() {
	$BBX echo "<1>DUMP ss.config" > /dev/kmsg
	$BBX echo "<1>BLOCK_SYSTEM=$BLOCK_SYSTEM" > /dev/kmsg
	$BBX echo "<1>SYSTEM_FSTYPE=$SYSTEM_FSTYPE" > /dev/kmsg
	$BBX echo "<1>BLOCK_USERDATA=$BLOCK_USERDATA" > /dev/kmsg
	$BBX echo "<1>USERDATA_FSTYPE=$USERDATA_FSTYPE" > /dev/kmsg
	$BBX echo "<1>BLOCK_CACHE=$BLOCK_CACHE" > /dev/kmsg
	$BBX echo "<1>BLOCK_BOOT=$BLOCK_BOOT" > /dev/kmsg
	$BBX echo "<1>SS_PART=$SS_PART" > /dev/kmsg
	$BBX echo "<1>SS_FSTYPE=$SS_FSTYPE" > /dev/kmsg
	$BBX echo "<1>SS_DIR=$SS_DIR" > /dev/kmsg
	$BBX echo "<1>HIJACK_BIN=$HIJACK_BIN" > /dev/kmsg
	$BBX echo "<1>BOOTMODE=$BOOTMODE" > /dev/kmsg
	$BBX echo "<1>CHECK_BOOTMODE=$CHECK_BOOTMODE" > /dev/kmsg
	$BBX echo "<1>DEVICE=$DEVICE" > /dev/kmsg
	$BBX echo "<1>CHARGER_MODE=$CHARGER_MODE" > /dev/kmsg
	$BBX echo "<1>POWERUP_REASON_TEMP=$POWERUP_REASON_TEMP" > /dev/kmsg
	$BBX echo "<1>POWERUP_REASON=$POWERUP_REASON" > /dev/kmsg
	$BBX echo "<1>POWERUP_REASON_CHARGER=$POWERUP_REASON_CHARGER" > /dev/kmsg
	$BBX echo "<1>BACKLIGHT_BRIGHTNESS_PATH=$BACKLIGHT_BRIGHTNESS_PATH" > /dev/kmsg
	$BBX echo "<1>BACKLIGHT_BRIGHTNESS_VALUE=$BACKLIGHT_BRIGHTNESS_VALUE" > /dev/kmsg
	$BBX echo "<1>TASKSET_CPUS=$TASKSET_CPUS" > /dev/kmsg
	$BBX echo "<1>SS_USE_DATAMEDIA=$SS_USE_DATAMEDIA" > /dev/kmsg
	$BBX echo "<1>DEBUG_MODE=$DEBUG_MODE" > /dev/kmsg
}

# unmount /sys/fs/selinux + clear out files
fixSELinux() {
	# HASH: disable for now
	if [ "1" = "0" ]; then
		echo "umount /sys/fs/selinux" > /dev/kmsg
		for i in $($BBX seq 1 10); do
			TMP=$($BBX mount | $BBX grep /sys/fs/selinux)
			if $BBX [[ -z "$TMP" ]] ; then
				break
			fi
			$BBX umount -l /sys/fs/selinux
			$BBX sleep 1
		done

		# make sure to erase SElinux files
		$BBX rm /file_contexts
		$BBX rm /property_contexts
		$BBX rm /seapp_contexts
		$BBX rm /sepolicy
		$BBX rm /sepolicy_version
	fi
}

logCurrentStatus() {
	$BBX echo "<1>LOG CURRENT STATUS:" > /dev/kmsg
#	$BBX echo "<1>$($BBX ls -l /init*)" > /dev/kmsg
#	$BBX echo "<1>______________________" > /dev/kmsg
	$BBX echo "<1>$($BBX mount)" > /dev/kmsg
	$BBX echo "<1>______________________" > /dev/kmsg
	$BBX echo "<1>$($BBX ls /proc/*/fd | grep system)" > /dev/kmsg
	$BBX echo "<1>______________________" > /dev/kmsg
#	$BBX echo "<1>$($BBX ps)" > /dev/kmsg
#	$BBX echo "<1>______________________" > /dev/kmsg
}
