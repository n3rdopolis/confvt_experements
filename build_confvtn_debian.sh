#! /bin/bash
if [[ $UID != 0 ]]
then
  echo "Must be root"
  exit 1
fi

apt-get update
KernelPackage=$(dpkg -l linux-image*|grep ^ii |grep meta-package |awk '{print $2}')
apt-get install -y build-essential fakeroot linux-source bc kmod cpio flex libncurses5-dev libelf-dev $KernelPackage

mkdir /tmp/buildkernel/
cd /tmp/buildkernel/

LatestSourceTar=$(ls /usr/src/linux-source-*.tar.xz |sort |tail -1)
LatestSourceFolder=$(basename $LatestSourceTar | sed 's/.tar.*z//g')
tar xavf $LatestSourceTar
cd /tmp/buildkernel/$LatestSourceFolder

InstalledKernelVersion=$(basename $(readlink -f /vmlinuz) | sed 's/vmlinuz-//g')
KernelMajorVersion=$(echo $InstalledKernelVersion | awk -F . '{print $1"."$2}')
cp /boot/config-$InstalledKernelVersion /tmp/buildkernel/$LatestSourceFolder/.config

sed -i 's/CONFIG_VT=y/# CONFIG_VT is not set'/g .config
sed -i 's/CONFIG_CONSOLE_TRANSLATIONS=y/# CONFIG_CONSOLE_TRANSLATIONS is not set'/g .config
sed -i 's/CONFIG_VT_CONSOLE=y/# CONFIG_VT_CONSOLE is not set'/g .config
sed -i 's/CONFIG_VT_CONSOLE_SLEEP=y/# CONFIG_VT_CONSOLE_SLEEP is not set'/g .config
sed -i 's/CONFIG_HW_CONSOLE=y/# CONFIG_HW_CONSOLE is not set'/g .config
sed -i 's/CONFIG_VT_HW_CONSOLE_BINDING=y/# CONFIG_VT_HW_CONSOLE_BINDING is not set'/g .config
sed -i 's/CONFIG_SYSTEM_TRUSTED_KEYS.*/CONFIG_SYSTEM_TRUSTED_KEYS=""/g' .config

make olddefconfig

make -j`nproc` bindeb-pkg

cd /tmp/buildkernel/
rm -r /tmp/buildkernel/$LatestSourceFolder/
rm /tmp/buildkernel/linux-image-*dbg*.deb
dpkg -i /tmp/buildkernel/linux-image-${KernelMajorVersion}*.deb
