#!/system/bin/sh

echo "enter tp self test"
echo "KIRIN_SelfTest_20181212.ini" > /sys/bus/i2c/devices/4-0038/fts_test

echo "Wait for TPselftest result......"
echo "Please adb pull /data/data/testdata.csv"
echo "Please adb pull /data/data/testresult.txt"
cat /sys/bus/i2c/devices/4-0038/fts_test
chmod 0777 /data/data/testdata.csv
chmod 0777 /data/data/testresult.txt
