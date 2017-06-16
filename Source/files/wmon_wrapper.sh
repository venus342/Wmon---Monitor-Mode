#! /system/bin/sh
LD_LIBRARY_PATH=/data/data/bcmon/libs LD_PRELOAD=/data/data/bcmon/libs/libfake_driver.so "$@"