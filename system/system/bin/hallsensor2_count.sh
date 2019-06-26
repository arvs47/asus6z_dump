#!/system/bin/sh

#cat hall sensor count
if [ "$1" == "1" ];then

    cat /sys/class/input/input3/device/lid2_count

fi
#count return to 0
if [ "$1" == "0" ];then

    echo 0 > /sys/class/input/input3/device/lid2_count
    echo "PASS"

fi
