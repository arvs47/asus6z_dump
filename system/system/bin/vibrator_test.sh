#!/system/bin/sh
#Enable/Disable vibrator script#

printENABLEOK(){
   echo "1"
}

printDISABLEOK(){
   echo "1"
}

if [ "$1" == "" ]; then
    echo "FAIL: wrong input Parameter"
    exit 0
fi
#Enable Touch
if [ "$1" == "1" ];then

    echo 25000 > /sys/class/input/input1/device/duration
    printENABLEOK

fi
#Disable Touch
if [ "$1" == "0" ];then

    echo 0 > /sys/class/input/input1/device/vibrator_on
    printDISABLEOK

fi
