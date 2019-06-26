#!/system/bin/sh

android_boot=`getprop sys.boot_completed`
downloadmode=`getprop persist.sys.downloadmode.enable`
platform=`getprop ro.build.product`
unlocked=`getprop atd.unlocked.ready`
stage=`getprop ro.boot.id.stage`
setenforce_modem_and_bt_prop=`getprop persist.vendor.modem.restart`
imei1=`getprop persist.radio.device.imei`
imei2=`getprop persist.radio.device.imei2`

# ZS630KL
if [ "$platform" != "ZS630KL" ]; then
	echo "It is not ZS630KL !!"
	exit
fi

# check boot complete
timeout=0
while [ "$android_boot" -ne "1" ]; do
	timeout=$(($timeout+1))
	if [ $timeout == 60 ]; then
		echo "timeout exit ($timeout)!!"
		exit
	fi
	echo "boot not ready !!"
	sleep 1
	android_boot=`getprop sys.boot_completed`
done
echo "boot ready ($android_boot)!!"

# check MP & unlock
if [ "$stage" == "7" ] && [ "$unlocked" == "0" ]; then
	# IMEI
	imei_result1=`grep -c "$imei1" /system/etc/IMEI_whitelist.txt`
	#echo "[Debug] check imei1 : $imei_result1" > /proc/asusevtlog
	imei_result2=`grep -c "$imei2" /system/etc/IMEI_whitelist.txt`
	#echo "[Debug] check imei2 : $imei_result2" > /proc/asusevtlog
	if [ "$imei_result1" == "1" ] || [ "$imei_result2" == "1" ]; then
		echo "[Debug] whitelist imei found !!" > /proc/asusevtlog
	else
		# RSASD 
		# wait 1 sec to get /sdcard/dat.bin
		sync
		sleep 1
		sync
		myShellVar=`(rsasd)`
		#myShellVar=`$(rsasd)`
		echo "[Debug] myShellVar = ($myShellVar)!!" > /proc/asusevtlog
		echo "[Debug] whitelist imei not found!!" > /proc/asusevtlog
		if [ "$myShellVar" == "13168" ]; then
			echo "[Debug] check rsasd : pass" > /proc/asusevtlog
		else
			echo "[Debug] check rsasd : fail" > /proc/asusevtlog
			echo "MP lock exit ($stage) !!"
			exit
		fi
	fi
fi

# check downloadmode flag & devcfg
modem_bit=$((setenforce_modem_and_bt_prop & 0x2))
if [ "$downloadmode" == "1" ] || [ "$modem_bit" == "2" ]; then
	echo asussetenforce:0 > /proc/rd
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/data/devcfg_system.mbn bs=1024 count=47
	dd if=/dev/block/sde15 of=/data/devcfg_check_a.mbn bs=1024 count=47
	dd if=/dev/block/sde35 of=/data/devcfg_check_b.mbn bs=1024 count=47
	devcfgcheck_a=`md5sum -b /data/devcfg_check_a.mbn`
	devcfgcheck_b=`md5sum -b /data/devcfg_check_b.mbn`
	devcfgsystem=`md5sum -b /data/devcfg_system.mbn`
	# Enable Coredump
	setprop persist.debug.trace 1
else
	exit
fi

# load devcfg
if [ "$devcfgcheck_a" != "$devcfgsystem" ] || [ "$devcfgcheck_b" != "$devcfgsystem" ]; then
	if [ "$platform" == "ZS630KL" ]; then
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde15
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde35
	fi
	echo "[Reboot] Enable DLmode & Load devcfg ($platform)" > /proc/asusevtlog
	reboot
else
	echo asussetenforce:1 > /proc/rd
	exit
fi
echo asussetenforce:1 > /proc/rd
