#!/bin/bash
RELEASE=$(date +"%Y-%m-%d")
OPENWRT=24.10.3
PROFILE=friendlyarm_nanopi-r3s
# Podkop
PODKOP=0.6.2
PODKOPR=r1
# AmneziaWG
AWG=24.10.3
R3S=aarch64_generic_rockchip_armv8
# ----------------------------------------------------------------------------------------
# NanoPi R3S
# ----------------------------------------------------------------------------------------
cd $HOME/tmp
# Downloads imagebulder
wget -O openwrt-imagebuilder-rkarmv8.tar.zst -q --show-progress -c \
https://downloads.openwrt.org/releases/"$OPENWRT"/targets/rockchip/armv8/openwrt-imagebuilder-"$OPENWRT"-rockchip-armv8.Linux-x86_64.tar.zst

# Распаковка
tar -xf openwrt-imagebuilder-rkarmv8.tar.zst
#zstd -d openwrt-imagebuilder-rkarmv8.tar.zst -c | tar -xf -

# Перейдем в imagebuilder
cd openwrt-imagebuilder-*-rockchip-armv8.Linux-x86_64

wget -O packages/podkop.ipk -q --show-progress -c \
https://github.com/itdoginfo/podkop/releases/download/"$PODKOP"/podkop-v"$PODKOP"-"$PODKOPR"-all.ipk

wget -O packages/luci-app-podkop.ipk -q --show-progress -c \
https://github.com/itdoginfo/podkop/releases/download/"$PODKOP"/luci-app-podkop-v"$PODKOP"-"$PODKOPR"-all.ipk

wget -O packages/luci-i18n-podkop-ru.ipk -q --show-progress -c \
https://github.com/itdoginfo/podkop/releases/download/"$PODKOP"/luci-i18n-podkop-ru-"$PODKOP".ipk

wget -O packages/amneziawg-tools.ipk -q --show-progress -c \
https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v"$AWG"/amneziawg-tools_v"$AWG"_"$R3S".ipk 

wget -O packages/kmod-amneziawg.ipk -q --show-progress -c \
https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v"$AWG"/kmod-amneziawg_v"$AWG"_"$R3S".ipk 

wget -O packages/luci-proto-amneziawg.ipk -q --show-progress -c \
https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v"$AWG"/luci-proto-amneziawg_v"$AWG"_"$R3S".ipk

wget -O packages/luci-i18n-amneziawg-ru.ipk -q --show-progress -c \
https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v"$AWG"/luci-i18n-amneziawg-ru_v"$AWG"_"$R3S".ipk

# Copy config's
mkdir -p files/etc/config
cp $HOME/config/r3s/* files/ 
chmod -R 777 files

# Building
make image PROFILE="$PROFILE" PACKAGES="-ip6tables -kmod-ip6tables -kmod-nf-conntrack6 -kmod-nf-ipt6 -odhcp6c -odhcpd -kmod-ipv6 \
luci luci-i18n-base-ru nano kmod-mtd-rw wireguard-tools kmod-wireguard luci-proto-wireguard qrencode \
podkop luci-app-podkop luci-i18n-podkop-ru banip luci-app-banip kmod-bonding \
amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-ru \
openvpn kmod-ovpn-dco-v2 kmod-tun zlib liblzo luci-app-openvpn" #FILES=files/

# Copy FW
mkdir -p "$HOME/release/$RELEASE"/{r3s}
cp $HOME/tmp/openwrt-imagebuilder-"$OPENWRT"-rockchip-armv8.Linux-x86_64/bin/targets/rockchip/armv8/* "$HOME/release/$RELEASE"/r3s

rm -rf $HOME/tmp/*
 
exit 0
