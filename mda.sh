#!/bin/bash
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mkdir -p /mnt/md{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /mnt/md$i; done



