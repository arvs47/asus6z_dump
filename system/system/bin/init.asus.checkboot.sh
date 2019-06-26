#!/system/bin/sh

android_boot=`getprop sys.boot_completed`
android_reboot_prop='sys.asus.android_reboot'
android_reboot=`getprop $android_reboot_prop`

# Check boot completed
if [ "$android_boot" == "1" ]; then
	if [ "$android_reboot" == "" ]; then
		setprop $android_reboot_prop 0
		echo "ASDF: 1st boot_completed...." > /proc/asusevtlog
	else
		android_reboot=$(($android_reboot+1))
		setprop $android_reboot_prop $android_reboot
		echo "[Debug]: Android restart....($android_reboot)" > /proc/asusevtlog
	fi
fi

# Check Coredump
debug_prop=`getprop persist.debug.trace`
if [ "$debug_prop" != "1" ]; then
	echo "exit($debug_prop)!!"
	exit
fi

SAVE_COREDUMP_DIR=/data/media/0/coredump
MaxDump=10
coredumped=`getprop sys.asus.coredumped`
coredump=`ls /data/core/ | grep -c ""`
dump="$SAVE_COREDUMP_DIR/core_`date +%Y%m%d-%H%M%S`.tar.gz"

if [ "$coredumped" == "" ]; then
    setprop sys.asus.coredumped 0
elif [ "$coredumped" == "0" ]; then
    setprop sys.asus.coredumped 1
fi

#tar
if [ "$coredumped" == "1" ]; then
    if [ $coredump -gt 0 ]; then
        mkdir -p $SAVE_COREDUMP_DIR
        chmod 771 $SAVE_COREDUMP_DIR
        tar -z -cf $dump . -C /data/core/
        setprop sys.asus.coredumped 2
    fi
fi

coredump_gz=`ls $SAVE_COREDUMP_DIR | grep -c core_`
if [ "$coredump_gz" -gt "$MaxDump" ]; then
    logs=`ls $SAVE_COREDUMP_DIR/core_*`
    oldest=$dump
    for f in $logs; do
        if [ $f -ot $oldest ]; then
            oldest=$f
        fi
    done
    rm -r $oldest
fi
