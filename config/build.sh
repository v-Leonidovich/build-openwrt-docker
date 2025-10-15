#!/bin/bash
# Настройки системы, wan, lan, wifi, dhcp, dns, podkop, пароль рут "/etc/passwd" "/etc/shadow"
# /etc/config/system - настройки системы, изменить hostname
# /etc/config/wireless - настройки Wifi
# /etc/config/prometheus-node-exporter-lua - option listen_interface 'lan' / wan / *
# /etc/config/podkop
RELEASE=$(date +"%Y-%m-%d")
OPENWRT=24.10.3
# Podkop
PODKOP=0.6.2
PODKOPR=r1
# AmneziaWG
AWG=24.10.3
R3S=aarch64_generic_rockchip_armv8
AX6S=aarch64_cortex-a53_mediatek_mt7622

#apt-get install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python3 python3-setuptools zstd -y

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

# Проверим PROFILE устройства
#make info

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

# Update
#scripts/feed update -a

mkdir -p files/etc/config
cp $HOME/config/r3s/* files/ 
chmod -R 777 files

# make с luci, prometheus, podkop, haproxy, nano и русификацией без ipv6 WireGuard/AmneziaWG #luci-app-pbr openconnect luci-proto-openconnect openvpn-openssl
make image PROFILE=friendlyarm_nanopi-r3s PACKAGES="-ip6tables -kmod-ip6tables -kmod-nf-conntrack6 -kmod-nf-ipt6 -odhcp6c -odhcpd -kmod-ipv6 \
luci luci-i18n-base-ru nano kmod-mtd-rw haproxy wireguard-tools kmod-wireguard luci-proto-wireguard qrencode \
prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-netstat \
prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations \
podkop luci-app-podkop luci-i18n-podkop-ru banip luci-app-banip kmod-bonding \
amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-ru \
openvpn kmod-ovpn-dco-v2 kmod-tun zlib liblzo luci-app-openvpn" #FILES=files/

# ----------------------------------------------------------------------------------------
# Xiaomi Redmi AX6S
# ----------------------------------------------------------------------------------------
cd $HOME/tmp
# Downloads imagebulder
wget -O openwrt-imagebuilder-mt7622.tar.zst -q --show-progress -c \
https://downloads.openwrt.org/releases/"$OPENWRT"/targets/mediatek/mt7622/openwrt-imagebuilder-"$OPENWRT"-mediatek-mt7622.Linux-x86_64.tar.zst

# Распаковка
tar -xf openwrt-imagebuilder-mt7622.tar.zst

# Перейдем в imagebuilder
cd openwrt-imagebuilder-*-mediatek-mt7622.Linux-x86_64

# Проверим PROFILE устройства
#make info

# Update
scripts/feed update -a

mkdir -p files/etc/config
cp $HOME/config/ax6s/* files/ 
chmod -R 777 files

# make с luci, prometheus, podkop, haproxy, nano и русификацией без ipv6
#luci-app-pbr haproxy podkop luci-app-podkop luci-i18n-podkop-ru banip luci-app-banip
make image PROFILE=xiaomi_redmi-router-ax6s PACKAGES="-ip6tables -kmod-ip6tables -kmod-nf-conntrack6 -kmod-nf-ipt6 -odhcp6c -odhcpd -kmod-ipv6 \
luci luci-i18n-base-ru nano kmod-mtd-rw \
prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-netstat \
prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations" # FILES=files/

# 
mkdir -p "$HOME/release/$RELEASE"/{r3s,ax6s}
cp $HOME/tmp/openwrt-imagebuilder-"$OPENWRT"-rockchip-armv8.Linux-x86_64/bin/targets/rockchip/armv8/* "$HOME/release/$RELEASE"/r3s
cp $HOME/tmp/openwrt-imagebuilder-"$OPENWRT"-mediatek-mt7622.Linux-x86_64/bin/targets/mediatek/mt7622/* "$HOME/release/$RELEASE"/ax6s

rm -rf $HOME/tmp/*
 
exit 0