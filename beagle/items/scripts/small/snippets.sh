Start qemu
qemu-system-arm -nographic -bios u-boot.bin -machine virt -smp cpus=1,cores=1,maxcpus=4 -chardev stdio,id=serialcon -serial chardev:serialcon -chardev socket,id=moncon,host=localhost,port=1235,server=on,wait=off -mon moncon -device virtio-net-device,netdev=qnet,mac=34:12:34:12:34:12 -netdev socket,id=qnet,connect=localhost:1236
~/programs/qemu/bin/qemu-system-aarch64 -bios u-boot.bin -nographic -machine virt -smp cpus=1,cores=1,maxcpus=4 -chardev stdio,id=serialcon -serial chardev:serialcon -chardev socket,id=moncon,host=localhost,port=1235,server=on,wait=off -mon moncon -device virtio-net-device,netdev=qnet,mac=34:12:34:12:34:12 -netdev tap,id=qnet,ifname=tap0,script=no


QEMU
  Connect qemu network backend TCP socket to our virtual networks boots (67) port
  sudo socat -v TCP-LISTEN:1236 UDP:10.0.1.128:67
  
  Continuously open monitor on ::1235
  while true; do sudo socat TCP:localhost:1235 -; test $? && sleep 1; done
 
TFTP and DHCPD
  # run tftp in our unique netns
  # might need -u kyle flag
  sudo ip netns exec vlan /usr/sbin/in.tftpd -L -s /mnt/harddisk/beagle/tftpboot/

  sudo ip netns exec vlan /usr/sbin/dhcpd -d -f -cf /etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid
  
