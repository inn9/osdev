CC      = i686-elf-gcc
CFLAGS  = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LD      = i686-elf-ld
AS 		= i686-elf-as

OBJFILES = \
	init.o \
	stdlib.o \
	tty.o \
	main.o

image:
	@echo "Creating hdd.img..."
	@dd if=/dev/zero of=./hdd.img bs=512 count=16065 1>/dev/null 2>&1

	@echo "Creating bootable first FAT32 partition..."
	@losetup /dev/loop1 ./hdd.img
	@(echo c; echo u; echo n; echo p; echo 1; echo ;  echo ; echo a; echo 1; echo t; echo c; echo w;) | fdisk /dev/loop1 1>/dev/null 2>&1 || true

	@echo "Mounting partition to /dev/loop2..."
	@losetup /dev/loop2 ./hdd.img \
    --offset    `echo \`fdisk -lu /dev/loop1 | sed -n 10p | awk '{print $$3}'\`*512 | bc` \
    --sizelimit `echo \`fdisk -lu /dev/loop1 | sed -n 10p | awk '{print $$4}'\`*512 | bc`
	@losetup -d /dev/loop1

	@echo "Format partition..."
	@mkdosfs /dev/loop2

	@echo "Copy kernel and grub files on partition..."
	@mkdir -p tempdir
	@mount /dev/loop2 tempdir
	@mkdir tempdir/boot
	@cp -r grub tempdir/boot/
	@cp myos.bin tempdir/
	@sleep 1
	@umount /dev/loop2
	@rm -r tempdir
	@losetup -d /dev/loop2

	@echo "Installing GRUB..."
	@echo "device (hd0) hdd.img \n \
	       root (hd0,0)         \n \
	       setup (hd0)          \n \
	       quit\n" | grub --batch 1>/dev/null
	@echo "Done!"

all: myos.bin
rebuild: clean all
.s.o:
	$(AS) -o $@ $<
.c.o: $(HEADERS)
	$(CC) -o $@ -c $< $(CFLAGS)
myos.bin: $(OBJFILES)
	$(CC) -T link.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc
clean:
	rm -f $(OBJFILES) myos.bin hdd.img
start:
	qemu-system-i386 -hda hdd.img