#!/bin/sh

shelldir="`dirname $0`"
export PATH="${shelldir}:$PATH"

for ss in `adb devices|grep '[[:space:]]\+device$' | awk '{print $1}'`
do
echo ["$ss"]
adb  -s "$ss" shell cat /system/build.prop|grep -E 'brand=|model=|release=|\.name='
echo ""
done
