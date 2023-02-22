root@rk3318-box:/media# sudo modprobe loop
root@rk3318-box:/media# sudo losetup -f
/dev/loop0
root@rk3318-box:/media# sudo losetup /dev/loop0 test.img
root@rk3318-box:/media# sudo fdisk -l /dev/loop0
Disk /dev/loop0: 14.41 GiB, 15476981760 bytes, 30228480 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb6cf9c7

Device       Boot Start      End  Sectors  Size Id Type
/dev/loop0p1      32768 29917183 29884416 14.3G 83 Linux
root@rk3318-box:/media# partprobe /dev/loop0
root@rk3318-box:/media# sudo e2fsck -f /dev/loop0
loop0    loop0p1  
root@rk3318-box:/media# sudo e2fsck -f /dev/loop0p1 
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/loop0p1: 251152/924768 files (0.2% non-contiguous), 1617844/3735552 blocks
root@rk3318-box:/media# sudo resize2fs -M /dev/loop0p1 
resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/loop0p1 to 1628336 (4k) blocks.
The filesystem on /dev/loop0p1 is now 1628336 (4k) blocks long.

root@rk3318-box:/media# sudo resize2fs -M /dev/loop0p1 
resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/loop0p1 to 1617129 (4k) blocks.
The filesystem on /dev/loop0p1 is now 1617129 (4k) blocks long.

root@rk3318-box:/media# sudo resize2fs -M /dev/loop0p1 
resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/loop0p1 to 1617107 (4k) blocks.
The filesystem on /dev/loop0p1 is now 1617107 (4k) blocks long.

root@rk3318-box:/media# sudo resize2fs -M /dev/loop0p1 
resize2fs 1.46.5 (30-Dec-2021)
The filesystem is already 1617107 (4k) blocks long.  Nothing to do!

root@rk3318-box:/media# sudo fdisk /dev/loop0

Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/loop0: 14.41 GiB, 15476981760 bytes, 30228480 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb6cf9c7

Device       Boot Start      End  Sectors  Size Id Type
/dev/loop0p1      32768 29917183 29884416 14.3G 83 Linux

Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): 

Using default response p.
Partition number (1-4, default 1): 
First sector (2048-30228479, default 2048): 32768
Last sector, +/-sectors or +/-size{K,M,G,T,P} (32768-30228479, default 30228479): +6.2
Last sector, +/-sectors or +/-size{K,M,G,T,P} (32768-30228479, default 30228479): +6.2G

Created a new partition 1 of type 'Linux' and of size 6.2 GiB.
Partition #1 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: n

Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Re-reading the partition table failed.: Invalid argument

The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or partx(8).

root@rk3318-box:/media# sudo e2fsck -f /dev/loop0p1 
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/loop0p1: 251152/405600 files (0.4% non-contiguous), 1584848/1617107 blocks
root@rk3318-box:/media# sudo partprobe /dev/loop0
root@rk3318-box:/media# sudo fdisk -l /dev/loop0
Disk /dev/loop0: 14.41 GiB, 15476981760 bytes, 30228480 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb6cf9c7

Device       Boot Start      End  Sectors  Size Id Type
/dev/loop0p1      32768 13035519 13002752  6.2G 83 Linux
root@rk3318-box:/media# sudo losetup -d /dev/loop0
root@rk3318-box:/media# fdisk -l test.img 
Disk test.img: 14.41 GiB, 15476981760 bytes, 30228480 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb6cf9c7

Device     Boot Start      End  Sectors  Size Id Type
test.img1       32768 13035519 13002752  6.2G 83 Linux
root@rk3318-box:/media# $ truncate --size=$[(13035519+1)*512] test.img
-bash: $: command not found
root@rk3318-box:/media# truncate --size=$[(13035519+1)*512] test.img
