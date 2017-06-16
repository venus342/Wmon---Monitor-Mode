#!/bin/bash
svc wifi disable
LD_LIBRARY_PATH=/data/data/com.bcmon.bcmon/files/libs
LD_PRELOAD=/data/data/com.bcmon.bcmon/files/libs/libfake_driver.so sh
cd /data/data/com.bcmon.bcmon/files/tools
./enable_bcmon
echo "rfasuccess"
exit