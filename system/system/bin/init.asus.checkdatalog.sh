#!/system/bin/sh

is_datalog_exist=`ls /data | grep logcat_log`
is_startlog=`getprop persist.asus.startlog`
version_type=`getprop ro.build.type`
logcat_filenum=`getprop persist.asus.logcat.filenum`
is_clear_logcat_logs=`getprop sys.asus.logcat.clear`
build_product=`getprop ro.build.product`
MAX_ROTATION_NUM=30

function start_logcat_services() {
    start logcat
    start logcat-radio
    start logcat-events
    start logcat-kernel
    stop logcat-asdf
}

function stop_logcat_services() {
    stop logcat
    stop logcat-radio
    stop logcat-events
    stop logcat-kernel
    start logcat-asdf
}

if [ "$is_clear_logcat_logs" == "1" ]; then
	if [ "$logcat_filenum" != "3" ] && [ "$logcat_filenum" != "10" ] && [ "$logcat_filenum" != "20" ] && [ "$logcat_filenum" != "30" ]; then
		#if logcat_filenum get failed, sleep 1s and retry
		sleep 1
		logcat_filenum=`getprop persist.asus.logcat.filenum`

		if [ "$logcat_filenum" == "" ]; then
			logcat_filenum=20
		fi
	fi

	file_counter=$MAX_ROTATION_NUM
	while [ $file_counter -gt $logcat_filenum ]; do
		if [ $file_counter -lt 10 ]; then
			file_counter=0$file_counter;
		fi

		if [ -e /data/logcat_log/logcat.txt.$file_counter ]; then
			rm -f /data/logcat_log/logcat.txt.$file_counter
		fi

		if [ -e /data/logcat_log/logcat-events.txt.$file_counter ]; then
			rm -f /data/logcat_log/logcat-events.txt.$file_counter
		fi

		if [ -e /data/logcat_log/logcat-radio.txt.$file_counter ]; then
			rm -f /data/logcat_log/logcat-radio.txt.$file_counter
		fi

		if [ -e /data/logcat_log/kernel-$file_counter.log.gz ]; then
			rm -f /data/logcat_log/kernel-$file_counter.log.gz
		fi

		file_counter=$(($file_counter-1))
	done

	setprop sys.asus.logcat.clear "0"
fi

# for EMS log
if [ "$is_clear_logcat_logs" == "2" ]; then
    rm -f /data/logcat_log/*
    start logcat-clean
    setprop sys.asus.logcat.clear "0"
fi

if [ -n "$is_datalog_exist" ]; then
    chown system.system /data/logcat_log
    chmod 0775 /data/logcat_log
fi

if [ "$is_startlog" == "1" ]; then
    start_logcat_services
elif [ "$is_startlog" == "0" ]; then
    stop_logcat_services
else
	start logcat-asdf
    setprop persist.asus.autosavelogmtp 0
    if [ "$version_type" == "userdebug" ] || [ "$version_type" == "eng" ]; then
        setprop persist.asus.startlog 1
        start_logcat_services
    fi
fi

# for Coredump
if [ "$build_product" == "ZS630KL" ]; then
	echo 1 > /proc/coredump
fi
