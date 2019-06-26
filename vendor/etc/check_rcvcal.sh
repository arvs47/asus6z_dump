#!/system/bin/sh

check_audio_calibration=`getprop audio.calibration.rcv`

echo "[ASUS][ReceiverCalibration] Begin Check Receiver calibration status" > /dev/kmsg
log -p d -t [ASUS][ReceiverCalibration] Begin Check Receiver calibration status

echo "[ASUS][ReceiverCalibration] Check Receiver calibration status audio.calibration.rcv = $check_audio_calibration" > /dev/kmsg
log -p d -t [ASUS][ReceiverCalibration] Check Receiver calibration status audio.calibration.rcv = $check_audio_calibration

if [ "${check_audio_calibration}" != "pass" ];
	then
	echo "[ASUS][ReceiverCalibration] Without Receiver calibration property" > /dev/kmsg
	log -p d -t [ASUS][ReceiverCalibration] Without Receiver calibration property

	if [ ! -f "/vendor/factory/cal_s_receiver0_log.txt" ];then
		echo "[ASUS][ReceiverCalibration] Original /vendor/factory/cal_s_receiver0_log.txt does not exist" > /dev/kmsg
		log -p d -t [ASUS][ReceiverCalibration] Original /vendor/factory/cal_s_receiver0_log.txt does not exist
	else
		check_audio_calibration_data=$(cat /vendor/factory/cal_s_receiver0_log.txt)
		echo "[ASUS][ReceiverCalibration] Original /vendor/factory/cal_s_receiver0_log.txt = $check_audio_calibration_data" > /dev/kmsg
		log -p d -t [ASUS][ReceiverCalibration] Original /vendor/factory/cal_s_receiver0_log.txt = $check_audio_calibration_data
	fi

	if [ ! -f "/mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt" ];then
		echo "[ASUS][ReceiverCalibration] Without asusfw Receiver calibration data, begin calibration again" > /dev/kmsg
		log -p d -t [ASUS][ReceiverCalibration] Without Receiver calibration data, begin calibration again
		Temp_data=`climax -d /dev/i2c-1 --slave=0x34 -r 0xf5`
		echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_receiver0_data_tmp.txt
		/vendor/bin/ReceiverCalibrationTest 5 > /dev/null
	else
		check_audio_calibration_data=$(cat /mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt)
		if [ "${check_audio_calibration_data}" == "0" ];
			then
			echo "[ASUS][ReceiverCalibration] /mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt = $check_audio_calibration_data still need calibration" > /dev/kmsg
			log -p d -t [ASUS][ReceiverCalibration] /mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt = $check_audio_calibration_data still need calibration
			Temp_data=`climax -d /dev/i2c-1 --slave=0x34 -r 0xf5`
			echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_receiver0_data_tmp.txt
			/vendor/bin/ReceiverCalibrationTest 5 > /dev/null

		else
			echo "[ASUS][ReceiverCalibration] Old /mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt = $check_audio_calibration_data still begin calibration" > /dev/kmsg
			log -p d -t [ASUS][ReceiverCalibration] Old /mnt/vendor/asusfw/audio/cal_self_receiver0_log.txt = $check_audio_calibration_data  still begin calibration
			Temp_data=`climax -d /dev/i2c-1 --slave=0x34 -r 0xf5`
			echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_receiver0_data_tmp.txt
			/vendor/bin/ReceiverCalibrationTest 5 > /dev/null
		fi
	fi

else
	echo "[ASUS][ReceiverCalibration] Receiver already calibrated" > /dev/kmsg
	log -p d -t [ASUS][ReceiverCalibration] Receiver already calibrated
fi
