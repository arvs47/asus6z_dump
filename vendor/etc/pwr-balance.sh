#!/vendor/bin/sh -x
#This is balance mode

#enable DPST function
#echo 2 > /proc/cabc_mode_switch

setprop persist.asus.power.mode balance

cabc=3
status=0
echo $status > /proc/driver/touch_charger_mode
echo $cabc > /proc/driver/cabc
