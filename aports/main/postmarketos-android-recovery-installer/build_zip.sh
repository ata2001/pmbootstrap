#!/bin/ash
set -e

# Copy files to the destination specified
# $1: files
# $2: destination
copy_files()
{
	for file in $1; do
		filename=$(basename "$file")
		install -Dm755 "$file" "$2"/"$filename"
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

# shellcheck disable=SC1091
. ./install_options

BINARIES="/sbin/cryptsetup /sbin/kpartx /usr/sbin/parted /usr/sbin/partprobe"
# shellcheck disable=SC2086
LIBRARIES=$(lddtree -l $BINARIES | awk '/lib/ {print}' | sort -u)
copy_files "$BINARIES" bin/
copy_files "$LIBRARIES" lib/
check_whether_exists rootfs.tar.gz
[ "$FLASH_BOOT" = "true" ] && check_whether_exists boot.img
zip -0 -r "pmos-$DEVICE.zip" .
