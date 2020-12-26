# Firecracker kata

Firecracker runs workloads in lightweight virtual machines, called microVMs,
which combine the security and isolation properties provided by hardware
virtualization technology with the speed and flexibility of containers.


## Getting kernel and rootfs
references: [firecracker getting started]
```
bash get_kernel.sh
bash get_rootfs.sh
```


## Making rootfs larger
```
e2fsck -f hello-rootfs.ext4 &&
    resize2fs hello-rootfs.ext4 5G
```


## Setting up network on host os
references: [firecracker getting started]
```
sudo make network-up
```


## Running microVM
references: [firecracker getting started]
```
make vm-up
```
standard credentials
```
root
root
```


## Setting up network on microVM
references: [firecracker network setup]
```
echo "worker-1" > /etc/hostname

echo "nameserver 8.8.8.8" > /etc/resolv.conf

cat << EOF > /etc/init.d/net.eth0
#!/sbin/openrc-run

start() {
    ebegin "Bringing up network interface eth0"
    ip addr add 172.16.0.2/24 dev eth0
    ip link set eth0 up
    ip route add default via 172.16.0.1 dev eth0
    eend $?
}

stop() {
    ebegin "Shutting down network interface eth0"
    ip route del 172.16.0.1 dev eth0
    ip addr del 172.16.0.2/24 dev eth0
    ip link set eth0 down
    eend $?
}
EOF

chmod +x /etc/init.d/net.eth0
/etc/init.d/hostname restart
/etc/init.d/net.eth0 start
rc-update add net.eth0 default
```



[firecracker getting started]: https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md
[firecracker network setup]: https://github.com/firecracker-microvm/firecracker/blob/master/docs/network-setup.md
