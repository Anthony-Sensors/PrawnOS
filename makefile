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

.PHONY: clean
clean:
	@echo "Enter one of:"
	@echo "	clean_kernel - which deletes the untar'd kernel folder from build"
	@echo "	clean_ath - which deletes the untar'd ath9k driver folder from build"
	@echo "	clean_img - which deletes the built PrawnOS images, this is ran when make image is ran"
	@echo "	clean_all - which does all of the above"
	@echo "	in most cases none of these need to be used manually as most cleanup steps are handled automatically"

.PHONY: clean_kernel
clean_kernel:
	rm -rf build/linux-4.*

.PHONY: clean_ath
clean_ath:
	rm -rf build/open-ath9k-htc-firmware

.PHONY: clean_img
clean_img:
	rm -f PrawnOS-*-c201-libre-*GB.img

.PHONY: clean_all
clean_all:
	make clean_kernel
	make clean_ath
	make clean_img


.PHONY: kernel
kernel:
	scripts/buildKernel.sh

.PHONY: filesystem
filesystem:
	make clean_img
	scripts/buildDebianFs.sh

.PHONY: kernel_inject
kernel_inject: #Targets an already built .img and swaps the old kernel with the newly compiled kernel
	scripts/buildNewKernelIntoFS.sh

.PHONY: image
image:
	make clean_img
	scripts/buildKernel.sh
	scripts/buildDebianFs.sh

.PHONY: live_image
live_image:
	echo "TODO"

.PHONY: kernel_config
kernel_config:
	scripts/crossmenuconfig.sh
