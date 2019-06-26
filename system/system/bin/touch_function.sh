#!/system/bin/sh
#Enable/Disable touch irq script#

printENABLEOK(){
   echo "Enable OK"
}

printDISABLEOK(){
   echo "Disable OK"
}

if [ "$1" == "" ]; then
    echo "FAIL: wrong input Parameter"
    exit 0
fi
#Enable Touch
if [ "$1" == "1" ];then

    echo 1 > /sys/bus/i2c/devices/4-0038/disable_touch
    printENABLEOK

fi
#Disable Touch
if [ "$1" == "0" ];then

    echo 0 > /sys/bus/i2c/devices/4-0038/disable_touch
    printDISABLEOK

fi
