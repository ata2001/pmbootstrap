#!/bin/sh
set -e

# Copy files to the destination specified
# $1: files
# $2: destination
copy_files()
{
	for file in $1; do
		install -Dm755 "$file" "$2"/$(basename "$file")
	done
}

check_whether_exists()
{
	if [ ! -e "$1" ]
	then
		echo "$1 not found"
		return 1
	fi
}

. ./install_options
BINARIES="/sbin/cryptsetup /sbin/kpartx /usr/sbin/parted /usr/sbin/partprobe"
LIBRARIES=$(lddtree -l $BINARIES | awk '/lib/ {print}' | sort -u)
copy_files "$BINARIES" bin/
copy_files "$LIBRARIES" lib/
check_whether_exists rootfs.tar.gz
if [ $FLASH_BOOT == "true" ]
then
	check_whether_exists boot.img
fi
zip -r "pmos-$DEVICE.zip" .
