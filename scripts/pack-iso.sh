#!/bin/sh -e
#
# File:
# Purpose:
#

cd $(dirname "$0"); . ./common.sh; cd ..

exit_if_nonroot

tmp=squashfs.gz
{ cd $extract; find | cpio -o -H newc; } | gzip -2 > $tmp
cmd advdef -z4 $tmp
cmd mv $tmp $squashfs
cmd mkisofs -l -J -R -V TC-custom -no-emul-boot -boot-load-size 4 \
    -boot-info-table -b boot/isolinux/isolinux.bin \
    -c boot/isolinux/boot.cat -o $livecd1 $newiso

# eof