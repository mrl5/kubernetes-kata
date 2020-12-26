SHELL=/bin/bash

.PHONY: all help

all: help network-up network-down vm-up

network-up:
	ip tuntap add tap0 mode tap
	ip addr add 172.16.0.1/24 dev tap0
	ip link set tap0 up
	echo 1 > /proc/sys/net/ipv4/ip_forward
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT

network-down:
	ip link del tap0
	echo 0 > /proc/sys/net/ipv4/ip_forward
	sh /root/firewall

vm-up:
	rm -f /tmp/firecracker.socket
	/usr/bin/firecracker --api-sock /tmp/firecracker.socket --config-file ./conf.json

help:
	@echo Firecracker kata
	@echo
	@echo "For available targets type: 'make ' and hit TAB"
	@echo
