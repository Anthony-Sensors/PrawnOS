#!/bin/sh -xe

#Build kenerl, wifi firmware


# This file is part of PrawnOS (http://www.prawnos.com)
# Copyright (c) 2018 Hal Emmerich <hal@halemmerich.com>

# PrawnOS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.

# PrawnOS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with PrawnOS.  If not, see <https://www.gnu.org/licenses/>.


KVER=4.17.19
TEST_PATCHES=false

ROOT_DIR=`pwd`
RESOURCES=$ROOT_DIR/resources/BuildResources


[ ! -d build ] && mkdir build
cd build
# build Linux-libre, with ath9k_htc
[ ! -f linux-libre-$KVER-gnu.tar.lz ] && wget https://www.linux-libre.fsfla.org/pub/linux-libre/releases/$KVER-gnu/linux-libre-$KVER-gnu.tar.lz
[ ! -d linux-$KVER ] && tar --lzip -xvf linux-libre-$KVER-gnu.tar.lz && FRESH=true
cd linux-$KVER
make clean
make mrproper
#Apply the usb and mmc patches if unapplied
[ "$FRESH" = true ] && for i in $RESOURCES/patches-tested/DTS/*.patch; do patch -p1 < $i; done
[ "$FRESH" = true ] && for i in $RESOURCES/patches-tested/kernel/*.patch; do patch -p1 < $i; done
#Apply all of the rockMyy patches that make sense
[ "$TEST_PATCHES" = true ] && for i in $RESOURCES/patches-untested/kernel/*.patch; do patch -p1 < $i; done
[ "$TEST_PATCHES" = true ] && for i in $RESOURCES/patches-untested/DTS/*.patch; do patch -p1 < $i; done

cp $RESOURCES/config .config
make -j `grep ^processor /proc/cpuinfo  | wc -l`  CROSS_COMPILE=arm-none-eabi- ARCH=arm zImage modules dtbs
[ ! -h kernel.its ] && ln -s $RESOURCES/kernel.its .
mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg
dd if=/dev/zero of=bootloader.bin bs=512 count=1
vbutil_kernel --pack vmlinux.kpart \
              --version 1 \
              --vmlinuz vmlinux.uimg \
              --arch arm \
              --keyblock /usr/share/vboot/devkeys/kernel.keyblock \
              --signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
              --config $RESOURCES/cmdline \
              --bootloader bootloader.bin
cd ..


# build AR9271 firmware
[ ! -d open-ath9k-htc-firmware ] && git clone --depth 1 https://github.com/qca/open-ath9k-htc-firmware.git
cd open-ath9k-htc-firmware
make toolchain
make -C target_firmware
cd ..
cd $ROOT_DIR
