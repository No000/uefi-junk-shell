#
# EDK2でブートローダをビルドする

# TotsugekitaiさんのMakefileから引用し、改変。
# https://github.com/Totsugekitai/minOSv2/blob/master/boot/Makefile

# target.txtを動的にリンクするようにする

SHELL = /bin/bash

.PHONY: default clean tool

ROOTDIR = $(CURDIR)
EDK_WORKSPACE = $(ROOTDIR)/tool/edk2
OVMF = $(ROOTDIR)/tool/OVMF/OVMF.fd


SHELL = /bin/bash


QEMU = qemu-system-x86_64
# メモリ指定
QEMU_OPTION += -m 1G
# シリアル通信をコンソールに接続
# QEMU_SERIAL = -serial mon:stdio
QEMU_OPTION += -d cpu_reset -bios $(OVMF) -hda fat:rw:test-hdd
# SMBIOSの設定
QEMU_OPTION += -smbios type=1,family=tetoto
# KVMサポート
# QEMU_OPTION += -enable-kvm -machine type=pc,accel=kvm
# マルチコアの設定
# QEMU_OPTION += -smp 2

ALL:

build:
	echo $(EDK_WORKSPACE)
	ln -sf $(ROOTDIR)/UefiJunkShellPkg $(EDK_WORKSPACE)
	cd ${EDK_WORKSPACE}; source edksetup.sh --reconfig;\
	build -p UefiJunkShellPkg/UefiJunkShell.dsc -b RELEASE -a X64 -t CLANG38 -n 4
	cp $(CURDIR)/tool/edk2/Build/UefiJunkShell/RELEASE_CLANG38/X64/UefiJunkShellPkg/UefiJunkShell/UefiJunkShell/OUTPUT/UefiJunkShell.efi ./output/BOOTX64.EFI

run:
	mkdir -p $(CURDIR)/test-hdd/EFI/BOOT
	cp $(CURDIR)/output/BOOTX64.EFI $(CURDIR)/test-hdd/EFI/BOOT/BOOTX64.EFI
	$(QEMU) $(QEMU_OPTION) $(QEMU_SERIAL)

tool: 
	cd ${EDK_WORKSPACE}; source edksetup.sh --reconfig;\
	build -p OvmfPkg/OvmfPkgX64.dsc -b RELEASE -a X64 -t CLANG38
	mkdir -p $(CURDIR)/tool/OVMF/
	cp $(CURDIR)/tool/edk2/Build/OvmfX64/RELEASE_CLANG38/FV/OVMF.fd ./tool/OVMF/
	cp $(CURDIR)/tool/edk2/Build/OvmfX64/RELEASE_CLANG38/FV/OVMF_CODE.fd ./tool/OVMF/
	cp $(CURDIR)/tool/edk2/Build/OvmfX64/RELEASE_CLANG38/FV/OVMF_VARS.fd ./tool/OVMF/

clean:
	$(RM) -r $(CURDIR)/test-hdd
	$(RM) $(CURDIR)/output/BOOTX64.EFI
	



