#!/bin/bash

sudo ip link del dev br0
sudo ip link del dev tap0

sudo ip link add br0 type bridge

sudo ip link set br0 up
sudo ip link set br0 multicast off promisc on

sudo ip tuntap add mode tap tap0
sudo ip link set tap0 up
sudo ip link set tap0 multicast off promisc on
sudo ip link set tap0 master br0

# sudo ip addr add 10.0.0.0/8 dev br0 noprefixroute
sudo ip addr flush dev br0
# sudo ip addr add 127.0.0.1 dev lo noprefixroute
sudo ip addr add 10.0.0.0/8 dev br0 noprefixroute

sudo ip route add 10.0.0.0/8 dev br0
sudo ip route del broadcast 10.0.0.0
