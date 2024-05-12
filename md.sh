#!/bin/bash
#Создаем масив raid10 из 4 дисков
mdadm --create --verbose /dev/md127 -l 10 -n 4 /dev/sd{b,c,d,e}
#Добовляем информацию о созданом масиве в mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
#Создаем gpt таблицу разделов и 5 разделов
parted -s /dev/md127 mklabel gpt
parted /dev/md127 mkpart primary ext4 0% 20%
parted /dev/md127 mkpart primary ext4 20% 40%
parted /dev/md127 mkpart primary ext4 40% 60%
parted /dev/md127 mkpart primary ext4 60% 80%
parted /dev/md127 mkpart primary ext4 80% 100%
#Создаем файловые системы на разделах
for i in $(seq 1 5); do mkfs.ext4 /dev/md127p$i; done
#Создаем дириктории и монтируем разделы
mkdir -p /mnt/md{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md127p$i /mnt/md$i; done
#Обновляем информацию в fstab
for i in $(seq 1 5); do blkid | grep md127p$i |awk '{print $2 }'| sed -e "s/\"//g; s,$, /mnt/md$i ext4 defaults 0 0," >> /etc/fstab; done
