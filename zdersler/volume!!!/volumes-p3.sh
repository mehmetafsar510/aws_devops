# PART 3 - AUTOMOUNT EBS VOLUMES AND PARTITIONS ON REBOOT


# back up the /etc/fstab file.
sudo cp /etc/fstab /etc/fstab.bak
# open /etc/fstab file and add the following info to the existing.(UUID's can also be used)

# /dev/xvdf       mnt/2nd-vol   ext4    defaults,nofail        0       0
# /dev/xvdg1      mnt/3rd-vol-part1   ext4  defaults,nofail        0       0
# /dev/xvdg2      mnt/3rd-vol-part2   ext4  defaults,nofail        0       0
sudo nano /etc/fstab  # sudo vim /etc/fstab   >>> for vim

# reboot and show that configuration exists (NOTE)
sudo reboot now
# list volumes to show current status, all volumes and partittions should be listed
lsblk
# show the used and available capacities related with volumes and partitions
df -h
# if there is data on it, check if the data still persists.
ls -lh /mnt/2nd-vol/
ls -lh /mnt/3rd-vol-part2/


# NOTE: You can use "sudo mount -a" to mount volumes and partitions after editing fstab file without rebooting.
##############################