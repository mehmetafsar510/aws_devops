# yeni volume ekleme

## aws console uzerinden yeni volume ekledik

**lsblk** ile bakiyoruz. mount point yok

[ec2-user@ip-172-31-89-120 ~]$ lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT  
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /
xvdf    202:80   0   4G  0 disk /mnt/2nd-vol
xvdg    202:96   0   2G  0 disk

**sudo fdisk -l** ile bagli volume lari listeliyoruz+

Disk /dev/xvda: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 66F46060-ED00-4D14-9841-F5CB6310A14A

Device       Start      End  Sectors Size Type
/dev/xvda1    4096 16777182 16773087   8G Linux filesystem
/dev/xvda128  2048     4095     2048   1M BIOS boot

Partition table entries are not in disk order.

Disk /dev/xvdf: 4 GiB, 4294967296 bytes, 8388608 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

### simdi volume partition islemleri yapacagiz

**sudo fdisk /dev/vxdg** komutu ile partitiona menusune giriyoruz

Welcome to fdisk (util-linux 2.30.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xc47f9e82.

Command (m for help):

**m** e basarak partition menusunun komutlarini aldik.

Help:

### DOS (MBR)

   a   toggle a bootable flag
   b   edit nested BSD disklabel
   c   toggle the dos compatibility flag

### Generic

   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

### Misc

   m   print this menu
   u   change display/entry units
   x   extra functionality (experts only)

### Script

   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

### Save & Exit

   w   write table to disk and exit
   q   quit without saving changes

### Create a new label

   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table

**n** harfi ile yeni partition ekliyoruz

tipini seciyouz

Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)

**p** ile primary sectik **1** secenegini tiklayip, diski bolumlere ayirmaya basliyoruz

#### ilk bolumu enterladik, sonra secon partition olarak 2100000 yazarak diski ikiye bolduk.

Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-4194303, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-4194303, default 4194303): 2100000

Created a new partition 1 of type 'Linux' and of size 1 GiB.

#### ikinci bolum icinde islemleri tekrarladik

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2):
First sector (2100001-4194303, default 2101248):
Last sector, +sectors or +size{K,M,G,T,P} (2101248-4194303, default 4194303):

Created a new partition 2 of type 'Linux' and of size 1022 MiB.

##### toplamda 2gb boyutundaki diski iki adet primary diske bolduk

**w** komutu ile degisiklikleri kaydedip cikiyoruz.
**q** komutu ise kaydetmeden cikiyor.

##### simdi yaptigimiz islemleri kontrol ediyoruz

**lsblk** ve **df -h** komutu ile 

lsblk komutunda hala bicimlendirilmemis disk bilgisi goruluyor

NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0    8G  0 disk
└─xvda1 202:1    0    8G  0 part /
xvdf    202:80   0    4G  0 disk /mnt/2nd-vol
xvdg    202:96   0    2G  0 disk
├─xvdg1 202:97   0    1G  0 part
└─xvdg2 202:98   0 1022M  0 part

df -h komutunda bicimlendirme yapmadigimiz disk gozukmuyor.

Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        474M     0  474M   0% /dev
tmpfs           492M     0  492M   0% /dev/shm
tmpfs           492M  416K  492M   1% /run
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.4G  6.7G  17% /
tmpfs            99M     0   99M   0% /run/user/1000
/dev/xvdf       3.9G  8.0M  3.7G   1% /mnt/2nd-vol

**sudo mkfs -t ext4 /dev/xvdg1** ile ilk diski
**sudo mkfs -t ext4 /dev/xvdg2** ile ikinci diski formatladik

**sudo mkdir /mnt/3rd_vloume-part1** ve **sudo mkdir /mnt/3rd_vloume-part2** ile 
diskleri baglayacagimiz klasorleri olusturduk

**sudo mount /dev/xvdg1 /mnt/3rd_vloume-part1** 
**sudo mount /dev/xvdg2 /mnt/3rd_vloume-part2** komutu ile belirledigimiz klasore bicimlenmis
volumleri mount ettik

**lsblk** ile volumleri goruyoruz

NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0    8G  0 disk 
└─xvda1 202:1    0    8G  0 part /
xvdf    202:80   0    4G  0 disk /mnt/2nd-vol
xvdg    202:96   0    2G  0 disk
├─xvdg1 202:97   0    1G  0 part /mnt/3rd_vloume-part2
└─xvdg2 202:98   0 1022M  0 part /mnt/3rd_vloume-part2


## aws console uzerinden size 3gb olacak sekilde modify islemi yaptim.

**lsblk** ile bakiyoruz

NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0    8G  0 disk 
└─xvda1 202:1    0    8G  0 part /
xvdf    202:80   0    4G  0 disk /mnt/2nd-vol
xvdg    202:96   0    3G  0 disk 
├─xvdg1 202:97   0    1G  0 part /mnt/3rd_vloume-part2
└─xvdg2 202:98   0 1022M  0 part /mnt/3rd_vloume-part2

sistem 3gb oldugunu goruyor, fakat yeni ekledigimiz bolumu resize yapacagiz ve bicimlendirecegiz.

**sudo growpart /dev/xvdg** ile size buyutuyoruz

**sudo resize2fs /dev/xvdg2** komutu ile 2.partition kismini genislettik

cd /etc ile etc klasorune indik. oradaki fstab dosyasini nano ile acip, ekledigimiz volumelarin 
otomatik sekilde mount olmasi icin asagidaki kaydi bu klasore ekliyoruz.

/dev/xvdf      /mnt/2nd-vol            ext4   defaults, nofail 0  0
/dev/xvdg1     /mnt/3rd_vloume-part1   ext4   defaults, nofail 0  0
/dev/xvdg2     /mnt/3rd_vloume-part2   ext4   defaults, nofail 0  0

reboot ettikten sonra, instance a yeniden baglandik ve **lsblk** ile 
volume bilgilerini aliyoruz. otomatik olarak mount oldugunu gorduk.

[ec2-user@ip-172-31-89-120 ~]$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0    8G  0 disk
└─xvda1 202:1    0    8G  0 part /
xvdf    202:80   0    4G  0 disk /mnt/2nd-vol
xvdg    202:96   0    3G  0 disk
├─xvdg1 202:97   0    1G  0 part /mnt/3rd_vloume-part1
└─xvdg2 202:98   0 1022M  0 part /mnt/3rd_vloume-part2