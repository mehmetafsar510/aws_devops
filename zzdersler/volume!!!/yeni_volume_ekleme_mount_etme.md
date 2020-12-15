# EBS Volume

**lsblk**
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /

## EC2 instance icin ekstra volume ihtiyaclarimzda ekleme yapabiliyoruz

**lslbk** komutu ile instance a eklenen volumelari gorebiliriz.
console uzerinden attach ettikten sonra linux terminalden baglantiya iliskin islemler yapacagiz

**sudo file -s /dev/xvdf**  komutu ile volume formatina bakiyoruz
*/dev/xvdf: Linux rev 1.0 ext4 filesystem data, UUID=16b013e6-0e93-4a50-9243-c768eb7b1549 (extents) (64bit) (large files) (huge files)*

**sudo mksf -t ext4 /dev/xvdf** ile volume linux formati olan ext4 ile formatlandi

**sudo mkdir /mnt/2nd-vol/** komutu ile yeni volume icin mnt klaöru altina yeni dosya olusturduk

**sudo mount /dev/xvdf /mnt/2nd-vol/** komutu ile formatladigimiz volumu, yeni olusturdugumuz 2nd-volu klasorune mount ettik

**lsblk** komutu ile yeni volume mount edilmis hali ile gozukuyor
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk 
└─xvda1 202:1    0   8G  0 part /
xvdf    202:80   0   2G  0 disk /mnt/2nd-vol
[ec2-user@ip-172-31-89-120 2nd-vol]$

**df -h** komutu ile instance a bagli volumelar listeleniyor
 [ec2-user@ip-172-31-89-120 2nd-vol]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        474M     0  474M   0% /dev
tmpfs           492M     0  492M   0% /dev/shm
tmpfs           492M  460K  492M   1% /run
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.4G  6.7G  17% /
tmpfs            99M     0   99M   0% /run/user/1000
tmpfs            99M     0   99M   0% /run/user/0
/dev/xvdf       2.0G  6.0M  1.8G   1% /mnt/2nd-vol  

**sudo touch ......washere.txt**
**ls** dosya olusturduk, ve icinde bilgi yazarak volume uzerinde islem yapabildigimizi gorduk

# aws console uzerinden volume size'i  2 gb den 4 gbye cikardik

**sudo resize2fs /dev/xvdf** komutu ile kapasitesini artirdigimiz volumun, yeni eklenen kismini formatladik

resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/xvdf is mounted on /mnt/2nd-vol; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/xvdf is now 1048576 blocks long.

**df -h** komutu ile instance a bagli volumelara bakiyoruz

Filesystem      Size  Used Avail Use% Mounted on    
devtmpfs        474M     0  474M   0% /dev
tmpfs           492M     0  492M   0% /dev/shm      
tmpfs           492M  460K  492M   1% /run
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.4G  6.7G  17% /
tmpfs            99M     0   99M   0% /run/user/1000
tmpfs            99M     0   99M   0% /run/user/0   
/dev/xvdf       3.9G  8.0M  3.7G   1% /mnt/2nd-vol

**sudo reboot now** komutu ile instance reboot ettik
reboot edildkten sonra **lsblk** ve **df -h** komutlari ile inceledigimizde, sistem reboot edildiginde bu zamana kadar yaptigimiz islemler kayboluyor.

**sudo file -s /dev/xvdf** komutu ile ext4 ile formatlanmis volumun durdugunu gorduk. mount etmeye ihtiyacimiz var

**sudo mount /dev/xvdf /mnt/2nd-vol/** komutu ile tekrar mount ettik

**lsblk** ve **df -h** komutu ile bakinca yeniden volume gozuktu.
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /
xvdf    202:80   0   4G  0 disk /mnt/2nd-vol

Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        474M     0  474M   0% /dev
tmpfs           492M     0  492M   0% /dev/shm
tmpfs           492M  404K  492M   1% /run
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.4G  6.7G  17% /
tmpfs            99M     0   99M   0% /run/user/1000
/dev/xvdf       3.9G  8.0M  3.7G   1% /mnt/2nd-vol