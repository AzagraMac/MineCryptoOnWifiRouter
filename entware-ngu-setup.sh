#!/bin/sh

export PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin$PATH

# Author: ryzhov_al
# Adapted by TeHashX / contact@hqt.ro
# Version: 3.1
# Mod: AzagraMac v1.0

BOLD="\033[1m"
NORM="\033[0m"
INFO="$BOLD Info: $NORM"
ERROR="$BOLD *** Error: $NORM"
WARNING="$BOLD * Warning: $NORM"
INPUT="$BOLD => $NORM"

i=1 # Will count available partitions (+ 1)
cd /tmp || exit

echo -e $INFO This script was created by ryzhov_al and modified by TeHashX.
echo -e $INFO Thanks @zyxmon \& @ryzhov_al for New Generation Entware
echo -e $INFO and @Rmerlin for his awesome firmwares
sleep 2
echo -e $INFO This script will guide you through the Entware installation.
echo -e $INFO Script modifies only \"entware\" folder on the chosen drive,
echo -e $INFO no other data will be touched. Existing installation will be
echo -e $INFO replaced with this one. Also some start scripts will be installed,
echo -e $INFO the old ones will be saved on partition where Entware is installed
echo -e $INFO like /tmp/mnt/sda1/jffs_scripts_backup.tgz
echo

if [ ! -d /jffs/scripts ] ; then
  echo -e "$ERROR Please \"Enable JFFS partition\" from \"Administration > System\""
  echo -e "$ERROR from router web UI: www.asusrouter.com/Advanced_System_Content.asp"
  echo -e "$ERROR then reboot router and try again. Exiting..."
  exit 1
fi

PLATFORM=$(uname -m)

if [ "$PLATFORM" == "aarch64" ]
then
   echo -e "$INFO This platform supports both 64bit and 32bit Entware installations."
   echo -e "$INFO 64bit support is recommended, but 32bit support may be required"
   echo -e "$INFO   if you are using other 32bit applications."
   echo -e "$INFO The 64bit installation is also better optimized for newer kernels."
   echo ""
   echo -en "$INPUT Do you wish to install the 64bit version? (y/n) "

  read -r choice
  case "$choice" in
   y|Y )
     echo -e "$INFO Installing the 64bit version.\n"
     PLATFORM="aarch64"
     ;;
  n|N )
     echo -e "$INFO Installing the 32bit version.\n"
     PLATFORM="armv7l"
     ;;
  * )
     echo -e "Invalid option - exiting...\n"
     exit
     ;;
  esac
fi

case $PLATFORM in
  armv7l)
    PART_TYPES='ext2|ext3|ext4'
    INST_URL='https://bin.entware.net/armv7sf-k2.6/installer/generic.sh'
    ENT_FOLD='entware'
    ;;
  mips)
    PART_TYPES='ext2|ext3'
    INST_URL='https://pkg.entware.net/binaries/mipsel/installer/installer.sh'
    ENT_FOLD='entware'
    ;;
  aarch64)
    PART_TYPES='ext2|ext3|ext4'
    INST_URL='https://bin.entware.net/aarch64-k3.10/installer/generic.sh'
	ENT_FOLD='entware'
    ;;	
  *)
    echo "This is an unsupported platform, sorry."
    exit 1
    ;;
esac

echo -e "$INFO Creating /jffs scripts backup..."
tar -czf "/tmp/mnt/sda1/jffs_backup_$(date +%F_%H-%M).tgz" /jffs/* >/dev/null

echo -e "$INFO Looking for available partitions..."
for mounted in $(/bin/mount | grep -E "$PART_TYPES" | cut -d" " -f3) ; do
  echo "[$i] --> $mounted"
  eval mounts$i="$mounted"
  i=$((i + 1))
done

if [ $i = "1" ] ; then
  echo -e "$ERROR No $PART_TYPES partitions available. Exiting..."
  exit 1
fi

echo -en "$INPUT Please enter partition number or 0 to exit\n$BOLD[0-$((i - 1))]$NORM: "
read -r partitionNumber
if [ "$partitionNumber" = "0" ] ; then
  echo -e "$INFO" Exiting...
  exit 0
fi

if [ "$partitionNumber" -gt $((i - 1)) ] ; then
  echo -e "$ERROR Invalid partition number! Exiting..."
  exit 1
fi

eval entPartition=\$mounts"$partitionNumber"
echo -e "$INFO $entPartition selected.\n"
entFolder="$entPartition/$ENT_FOLD"
entwareFolder="$entPartition/entware-ng"
entwarearmFolder="$entPartition/entware-ng.arm"
asuswareFolder="$entPartition/asusware"
asuswarearmFolder="$entPartition/asusware.arm"
optwFolder="$entPartition/optware"
optwareFolder="$entPartition/optware-ng"
optwarearmFolder="$entPartition/optware-ng.arm"

if [ -d /opt/debian ]
then
  echo -e "$WARNING Found chrooted-debian installation, stopping..."
  debian stop
fi

if [ -f /jffs/scripts/services-stop ]
then
  echo -e "$WARNING stopping running services..."
  /jffs/scripts/services-stop
fi

if [ -d "$entFolder" ] ; then
  echo -e "$WARNING Found previous entware-ng installation, saving..."
  mv "$entFolder" "$entFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$entwareFolder" ] ; then
  echo -e "$WARNING Found previous entware-ng.arm installation, saving..."
  mv "$entwareFolder" "$entwareFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$entwarearmFolder" ] ; then
  echo -e "$WARNING Found previous entware-ng installation, saving..."
  mv "$entwarearmFolder" "$entwarearmFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$asuswareFolder" ] ; then
  echo -e "$WARNING Found old optware installation, saving..."
  mv "$asuswareFolder" "$asuswareFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$asuswarearmFolder" ] ; then
  echo -e "$WARNING Found old optware.arm installation, saving..."
  mv "$asuswarearmFolder" "$asuswarearmFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$optwFolder" ] ; then
  echo -e "$WARNING Found optware installation, saving..."
  mv "$optwFolder" "$optwFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$optwareFolder" ] ; then
  echo -e "$WARNING Found optware-ng installation, saving..."
  mv "$optwareFolder" "$optwareFolder-old_$(date +%F_%H-%M)"
fi

if [ -d "$optwarearmFolder" ] ; then
  echo -e "$WARNING Found optware.ng.arm installation, saving..."
  mv "$optwarearmFolder" "$optwarearmFolder-old_$(date +%F_%H-%M)"
fi

echo -e "$INFO Creating $entFolder folder..."
mkdir "$entFolder"

if [ -d /tmp/opt ] ; then
  echo -e "$WARNING Deleting old /tmp/opt symlink..."
  rm /tmp/opt
fi

echo -e "$INFO Creating /tmp/opt symlink..."
ln -sf "$entFolder" /tmp/opt

echo -e "$INFO Modifying start scripts..."
cat > /jffs/scripts/services-start << EOF
#!/bin/sh

RC='/opt/etc/init.d/rc.unslung'

i=30
until [ -x "\$RC" ] ; do
  i=\$((\$i-1))
  if [ "\$i" -lt 1 ] ; then
    logger "Could not start Entware"
    exit
  fi
  sleep 5
done
\$RC start
EOF
chmod +x /jffs/scripts/services-start

cat >> /jffs/scripts/services-stop << EOF

/opt/etc/init.d/rc.unslung stop
EOF
chmod +x /jffs/scripts/services-stop

cat > /jffs/scripts/post-mount << EOF
#!/bin/sh

if [ -f /tmp/mnt/sda1/file.swp ]
then
  echo -e "- Mounting swap file..."
  swapon /tmp/mnt/sda1/file.swp
else
  echo -e "Swap file not found or /tmp/mnt/sda1 is not mounted..."
fi

EOF

eval sed -i 's,__Partition__,$entPartition,g' /jffs/scripts/post-mount
chmod +x /jffs/scripts/post-mount

cat > /jffs/scripts/unmount << 'EOF'
#!/bin/sh

awk '/SwapTotal/ {if($2>0) {system("swapoff /tmp/mnt/sda1/file.swp")} else print "Swap not mounted"}' /proc/meminfo
EOF
chmod +x /jffs/scripts/unmount

if [ "$(nvram get jffs2_scripts)" != "1" ] ; then
  echo -e "$INFO Enabling custom scripts and configs from /jffs..."
  nvram set jffs2_scripts=1
  nvram commit
fi

wget -qO - $INST_URL | sh
opkg install terminfo

# Swap file
while :
do
    clear
    echo Router model `cat "/proc/sys/kernel/hostname"`
    echo "---------"
    echo "SWAP FILE"
    echo "---------"
    echo "Choose swap file size (Highly Recommended)"
    echo "1. 1GB"
    echo "2. 2GB"
    echo "3. 4GB (recommended for MySQL Server or PlexMediaServer)"	
    echo "4. Skip this step, I already have a swap file / partition"
    echo "   or I don't want to create one right now"
    read -p "Enter your choice [ 1 - 4 ] " choice
    case "$choice" in
        1) 
            echo -e "$INFO Creating a 1GB swap file..."
            echo -e "$INFO This could take a while, be patient..."
            dd if=/dev/zero of=/tmp/mnt/sda1/file.swp bs=1024 count=1048576
            mkswap /tmp/mnt/sda1/file.swp
            chmod 0600 /tmp/mnt/sda1/file.swp
            swapon /tmp/mnt/sda1/file.swp
            read -p "Press [Enter] key to continue..." readEnterKey
			free
			break
            ;;
        2)
            echo -e "$INFO Creating a 2GB swap file..."
            echo -e "$INFO This could take a while, be patient..."
            dd if=/dev/zero of=/tmp/mnt/sda1/file.swp bs=1024 count=2097152
            mkswap /tmp/mnt/sda1/file.swp
            chmod 0600 /tmp/mnt/sda1/file.swp
			swapon /tmp/mnt/sda1/file.swp
            read -p "Press [Enter] key to continue..." readEnterKey
			free
			break
            ;;
        3)
            echo -e "$INFO Creating a 4GB swap file..."
            echo -e "$INFO This could take a while, be patient..."
            dd if=/dev/zero of=/tmp/mnt/sda1/file.swp bs=1024 count=4194304
            mkswap /tmp/mnt/sda1/file.swp
            chmod 0600 /tmp/mnt/sda1/file.swp
			swapon /tmp/mnt/sda1/file.swp
            read -p "Press [Enter] key to continue..." readEnterKey
			free
			break
            ;;			
        4)
            free
			break
            ;;
        *)
            echo "ERROR: INVALID OPTION!"			
			echo "Press 1 to create a 512MB swap file"
			echo "Press 2 to create a 1024MB swap file"
			echo "Press 3 to create a 2048MB swap file (for Mysql or Plex)"			
			echo "Press 4 to skip swap creation (not recommended)" 
            read -p "Press [Enter] key to continue..." readEnterKey
            ;;
    esac	
done

cat > /opt/bin/entware-services << EOF
#!/bin/sh

export PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin$PATH

case "\$1" in
 start)
   sh /jffs/scripts/services-start
   ;;
 stop)
   sh /jffs/scripts/services-stop
   ;;
 restart)
   sh /jffs/scripts/services-stop
   echo -e Restarting Entware Installed Services...
   sleep 2
   sh /jffs/scripts/services-start
   ;;
 *)
   echo "Usage: services {start|stop|restart}" >&2
   exit 3
   ;;
esac
EOF
chmod +x /opt/bin/entware-services

cat << EOF

Congratulations! If there are no errors above then Entware is successfully initialized.

Found a Bug? Please report at https://github.com/Entware-ng/Entware-ng/issues

Type 'opkg install <pkg_name>' to install necessary package.

EOF
