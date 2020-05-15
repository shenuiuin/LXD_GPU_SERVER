#!/bin/bash
#####################################################################################################
# Script_Name : xrdp-installer-1.2.sh
# Description : Perform xRDP installation on Ubuntu 16.04,18.04,19.04,19.10 and perform
#               additional post configuration to improve end user experience
# Date : November 2019
# written by : Griffon
# WebSite :http://www.c-nergy.be - http://www.c-nergy.be/blog
# Version : 1.2
# History : 1.2   - Adding Support to Ubuntu 20.04 + Removed support for Ubuntu 19.04
#                 - Stricter Check for HWE Package (thanks to Andrej Gantvorg)
#                 - Changed code in checking where to copy image for login screen customization 
#                 - Fixed Bug checking SSL group membership 
#                 - Updating background color xrdp login screen 
#                 - Updating pkgversion to x.13 for checkinstall process
#         : 1.1   - Tackling multiple run of the script 
#                 - Improved checkinstall method/check ssl group memberhsip
#                 - Replaced ~/Downloads by a variable                 
#         : 1.0   - Added remove option + Final optimization                
#         : 0.9   - updated compile section to use checkinstall
#         : 0.8   - Updated the fix_theme function to add support for Ubuntu 16.04 
#         : 0.7   - Updated prereqs function to add support for Ubuntu 16.04
#         : 0.6   - Adding logic to detect Ubuntu version for U16.04 
#         : 0.5   - Adding env variable Fix 
#         : 0.4   - Adding SSL Fix 
#         : 0.3   - Adding custom login screen option  
#         : 0.2   - Adding new code for passing parameters  
#         : 0.1   - Initial Script (merging custom & Std)       
# Disclaimer : Script provided AS IS. Use it at your own risk....
#              You can use this script and distribute it as long as credits are kept 
#              in place and unchanged   
####################################################################################################

#--------------------------------------------------------------------------#
# -----------------------Function Section - DO NOT MODIFY -----------------#
#--------------------------------------------------------------------------#

############################################################################
# DEFAULT INSTALLATION MODE : STANDARD INSTALLATION 
############################################################################

#---------------------------------------------------#
# Function 1  - check xserver-xorg-core package....
#---------------------------------------------------#

check_hwe()
{
Release=$(lsb_release -sr)
echo
/bin/echo -e "\e[1;33m |-| Detecting xserver-xorg-core package installed \e[0m"

xorg_no_hwe_install_status=$(dpkg-query -W -f ='${Status}\n' xserver-xorg-core 2>/dev/null)
xorg_hwe_install_status=$(dpkg-query -W -f ='${Status}\n' xserver-xorg-core-hwe-$Release 2>/dev/null) 

if [[ "$xorg_hwe_install_status" =~ \ installed$ ]]
then
# – hwe version is installed on the system
/bin/echo -e "\e[1;32m 	|-| xorg package version: xserver-xorg-core-hwe \e[0m"
HWE="yes"
elif [[ "$xorg_no_hwe_install_status" =~ \ installed$ ]]
then
/bin/echo -e "\e[1;32m 	|-| xorg package version: xserver-xorg-core \e[0m"
HWE="no"
else
/bin/echo -e "\e[1;31m 	|-| Error checking xserver-xorg-core flavour \e[0m"
exit 1
fi
}

#---------------------------------------------------#
# Function 2  - Install xRDP Software....
#---------------------------------------------------#

install_xrdp()
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Installing XRDP Packages...Proceeding...  !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo
if [[ $HWE = "yes" ]] && [[ "$version" = *"Ubuntu 18.04"* ]];
then
	sudo apt-get install xrdp -y
	sudo apt-get install xorgxrdp-hwe-18.04
else
    sudo apt-get install xrdp -y
fi
}

############################################################################
# ADVANCED INSTALLATION MODE : CUSTOM INSTALLATION
############################################################################

#---------------------------------------------------#
# Function 0 - Install Prereqs...
#---------------------------------------------------#

install_prereqs() {
echo
Release=$(lsb_release -sr)
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Installing PreReqs packages..Proceeding.  ! \e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo
sudo apt-get -y install libx11-dev libxfixes-dev libssl-dev libpam0g-dev libtool libjpeg-dev flex bison gettext autoconf libxml-parser-perl libfuse-dev xsltproc libxrandr-dev python-libxml2 nasm fuse pkg-config git intltool checkinstall
echo
if [ $HWE = "yes" ];
then
	# - xorg-hwe-* to be installed
	/bin/echo -e "\e[1;32m       |-| xorg package version: xserver-xorg-core-hwe-$Release \e[0m"
	sudo apt-get install -y xserver-xorg-dev-hwe-$Release xserver-xorg-core-hwe-$Release	
else
	#-no-hwe
	/bin/echo -e "\e[1;32m       |-| xorg package version: xserver-xorg-core \e[0m"
	echo
	sudo apt-get install -y xserver-xorg-dev xserver-xorg-core
fi
}

#---------------------------------------------------#
# Function 1 - Download XRDP Binaries... 
#---------------------------------------------------#
get_binaries() { 
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Download xRDP Binaries.......Proceeding.  ! \e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo

#cd ~/Downloads
Dwnload=$(xdg-user-dir DOWNLOAD)
cd $Dwnload


## -- Download the xrdp latest files
echo
/bin/echo -e "\e[1;32m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;32m   !  Preparing download xrdp package            !\e[0m"
/bin/echo -e "\e[1;32m   !---------------------------------------------!\e[0m"
echo
git clone https://github.com/neutrinolabs/xrdp.git
echo
/bin/echo -e "\e[1;32m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;32m   !  Preparing download xorgxrdp package        !\e[0m"
/bin/echo -e "\e[1;32m   !---------------------------------------------!\e[0m"
echo
git clone https://github.com/neutrinolabs/xorgxrdp.git

}

#---------------------------------------------------#
# Function 2 - compiling xrdp... 
#---------------------------------------------------#
compile_source() { 
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Compile xRDP packages .......Proceeding.  ! \e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo

#cd ~/Downloads/xrdp
cd $Dwnload/xrdp

sudo ./bootstrap
sudo ./configure --enable-fuse --enable-jpeg --enable-rfxcodec
sudo make

#-- check if no error during compilation 
if [ $? -eq 0 ]
then 
/bin/echo -e "\e[1;33m   |-| Make Operation Completed successfully       \e[0m"
else 
echo
echo
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;31m   !   Error while Executing make                !\e[0m"
/bin/echo -e "\e[1;31m   !   The Script is exiting....                 !\e[0m"
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
exit
fi
sudo checkinstall --pkgname=xrdp --pkgversion=0.9.13 --pkgrelease=1 --default

#xorgxrdp package compilation
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Compile xorgxrdp packages....Proceeding.  ! \e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo

#cd ~/Downloads/xorgxrdp 
cd $Dwnload/xorgxrdp

sudo ./bootstrap 
sudo ./configure 
sudo make

# check if no error during compilation 
if [ $? -eq 0 ]
then 
echo
/bin/echo -e "\e[1;33m   |-| Make Operation Completed successfully       \e[0m"
echo
else 
echo
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;31m   !   Error while Executing make                !\e[0m"
/bin/echo -e "\e[1;31m   !   The Script is exiting....                 !\e[0m"
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
exit
fi
sudo checkinstall --pkgname=xorgxrdp --pkgversion=0.2.13 --pkgrelease=1 --default
}

#---------------------------------------------------#
# Function 3 - create services .... 
#---------------------------------------------------# 
enable_service() {
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Creating xRDP services.......Proceeding.  ! \e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo 
sudo systemctl daemon-reload
sudo systemctl enable xrdp.service
sudo systemctl enable xrdp-sesman.service
sudo systemctl start xrdp

}

############################################################################
# COMMON FUNCTIONS - WHATEVER INSTALLATION MODE 
############################################################################

#---------------------------------------------------#
# Function 0 - Install Gnome Tweak Tool.... 
#---------------------------------------------------#
install_tweak() 
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Installing Gnome Tweak...Proceeding...    !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo
sudo apt-get install gnome-tweak-tool -y
}

#--------------------------------------------------------------------#
# Fucntion 1 - Allow console Access ....(seems optional in u18.04)
#--------------------------------------------------------------------#
allow_console() 
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Granting Console Access...Proceeding...   !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
}

#---------------------------------------------------#
# Function 2 - create policies exceptions .... 
#---------------------------------------------------#
create_polkit()
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Creating Polkit File...Proceeding...      !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo

#All Ubuntu version
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

#Specific Versions
if [[ "$version" = *"Ubuntu 19.10"* ]] || [[ "$version" = *"Ubuntu 20.04"* ]] ;
then
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/46-allow-update-repo.pkla" <<EOF
[Allow Package Management all Users]
Identity=unix-user:*
Action=org.freedesktop.packagekit.system-sources-refresh
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
fi
}

#---------------------------------------------------#
# Function 3 - Fixing Theme and Extensions .... 
#---------------------------------------------------#
fix_theme()
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Fix Theme and extensions...Proceeding...  !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"

# Checking if script has run already 
if [ -f /etc/xrdp/startwm.sh.griffon ]
then
sudo rm /etc/xrdp/startwm.sh
sudo mv /etc/xrdp/startwm.sh.griffon /etc/xrdp/startwm.sh
fi 

#Backup the file before modifying it
sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.griffon

if  [[ "$version" = *"Ubuntu 16.04"* ]];
then
echo
sudo sed -i "/# auth /a cat >~/.xsession << EOF\n#Unity Xrdp multi-users \n/usr/lib/gnome-session/gnome-session-binary --session=ubuntu &\n/usr/lib/x86_64-linux-gnu/unity/unity-panel-service &\n/usr/lib/unity-settings-daemon/unity-settings-daemon &\nfor indicator in /usr/lib/x86_64-linux-gnu/indicator-*;\ndo\nbasename='basename \\\\\${indicator}'\ndirname='dirname \\\\\${indicator}'\nservice=\\\\\${dirname}/\\\\\${basename}/\\\\\${basename}-service\n\\\\\${service} &\ndone\nunity\nEOF" /etc/xrdp/startwm.sh
echo
else 
echo
sudo sed -i "4 a #Improved Look n Feel Method\ncat <<EOF > ~/.xsessionrc\nexport GNOME_SHELL_SESSION_MODE=ubuntu\nexport XDG_CURRENT_DESKTOP=ubuntu:GNOME\nexport XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg\nEOF\n" /etc/xrdp/startwm.sh
echo
fi
}

#---------------------------------------------------#
# Function 4 - Enable Sound Redirection .... 
#---------------------------------------------------#
enable_sound()
{
echo
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;33m   !   Enabling Sound Redirection...             !\e[0m"
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
echo

# Step 1 - Enable Source Code Repository
sudo apt-add-repository -s 'deb http://be.archive.ubuntu.com/ubuntu/ '$codename' main restricted'
sudo apt-add-repository -s 'deb http://be.archive.ubuntu.com/ubuntu/ '$codename' restricted universe main multiverse'
sudo apt-add-repository -s 'deb http://be.archive.ubuntu.com/ubuntu/ '$codename'-updates restricted universe main multiverse'
sudo apt-add-repository -s 'deb http://be.archive.ubuntu.com/ubuntu/ '$codename'-backports main restricted universe multiverse'
sudo apt-add-repository -s 'deb http://be.archive.ubuntu.com/ubuntu/ '$codename'-security main restricted universe main multiverse'
sudo apt-get update

# Step 2 - Install Some PreReqs
sudo apt-get install git libpulse-dev autoconf m4 intltool build-essential dpkg-dev libtool libsndfile-dev libcap-dev -y libjson-c-dev
sudo apt build-dep pulseaudio -y

# Step 3 -  Download pulseaudio source in /tmp directory - Do not forget to enable source repositories
cd /tmp
sudo apt source pulseaudio

# Step 4 - Compile
pulsever=$(pulseaudio --version | awk '{print $2}')
cd /tmp/pulseaudio-$pulsever
sudo ./configure

# step 5 - Create xrdp sound modules
sudo git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
cd pulseaudio-module-xrdp
sudo ./bootstrap 
sudo ./configure PULSE_DIR="/tmp/pulseaudio-$pulsever"
sudo make

#Step 6 copy files to correct location (as defined in /etc/xrdp/pulse/default.pa)
cd /tmp/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs
sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so
sudo install -t "/usr/lib/pulse-$pulsever/modules" -D -m 644 *.so
echo

}

#---------------------------------------------------#
# Function 5 - Custom xRDP Login Screen .... 
#---------------------------------------------------#
custom_login()
{
echo 
/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m" 
/bin/echo -e "\e[1;33m ! Customizing xRDP login screen               !\e[0m" 
/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m" 
echo 
Dwnload=$(xdg-user-dir DOWNLOAD)
echo "go to Download folder"
echo
echo $Dwnload
#cd ~/Downloads
cd $Dwnload
wget http://www.c-nergy.be/downloads/griffon_logo_xrdp.bmp

#Check if script has run once...
if [ -f /etc/xrdp/xrdp.ini.griffon ]
then
sudo rm /etc/xrdp/xrdp.ini
sudo mv /etc/xrdp/xrdp.ini.griffon /etc/xrdp/xrdp.ini
fi 

#Backup file 
sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.griffon

#Check where to copy the logo file
if [ -d "/usr/local/share/xrdp" ] 
then
    echo "Directory /path/to/dir exists." 
	sudo cp griffon_logo_xrdp.bmp /usr/local/share/xrdp
    sudo sed -i 's/ls_logo_filename=/ls_logo_filename=\/usr\/local\/share\/xrdp\/griffon_logo_xrdp.bmp/g' /etc/xrdp/xrdp.ini
else
    sudo cp griffon_logo_xrdp.bmp /usr/share/xrdp
	sudo sed -i 's/ls_logo_filename=/ls_logo_filename=\/usr\/share\/xrdp\/griffon_logo_xrdp.bmp/g' /etc/xrdp/xrdp.ini
fi

#4F194C
sudo sed -i 's/blue=009cb5/blue=dedede/' /etc/xrdp/xrdp.ini
sudo sed -i 's/#white=ffffff/white=dedede/' /etc/xrdp/xrdp.ini
sudo sed -i 's/#ls_title=My Login Title/ls_title=Remote Desktop for Linux/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_top_window_bg_color=009cb5/ls_top_window_bg_color=4F194C/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_bg_color=dedede/ls_bg_color=ffffff/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_logo_x_pos=55/ls_logo_x_pos=0/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_logo_y_pos=50/ls_logo_y_pos=5/' /etc/xrdp/xrdp.ini
}

#---------------------------------------------------#
# Function 6 - Fix SSL Minor Issue .... 
#---------------------------------------------------#
fix_ssl() 
{ 
echo 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
/bin/echo -e "\e[1;33m   ! Fixing SSL Cert Issue ...                   !\e[0m" 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
echo 
if id -Gn xrdp | grep ssl-cert 
then 
/bin/echo -e "\e[1;32m   !--xrdp already member ssl-cert...Skipping ---!\e[0m" 
else
	sudo adduser xrdp ssl-cert 
fi
}

#---------------------------------------------------#
# Function 7 - Fixing env variables in XRDP .... 
#---------------------------------------------------#
fix_env()
{
#Add this line to /etc/pam.d/xrdp-sesman if not present
if grep -Fxq "session required pam_env.so readenv=1 user_readenv=0" /etc/pam.d/xrdp-sesman 
   then
            echo "Env settings already set"
   else
		sudo sed -i '1 a session required pam_env.so readenv=1 user_readenv=0' /etc/pam.d/xrdp-sesman
 fi
}

#---------------------------------------------------#
# Function 8 - Removing XRDP Packages .... 
#---------------------------------------------------#
remove_xrdp()
{
echo 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
/bin/echo -e "\e[1;33m   ! Removing xRDP Packages...                   !\e[0m" 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
echo 
#remove xrdp package
sudo systemctl stop xrdp
sudo systemctl disable xrdp
sudo apt-get autoremove xrdp -y
sudo apt-get purge xrdp -y
#remove xorgxrdp
sudo systemctl stop xorgxrdp
sudo systemctl disable xorgxrdp 
sudo apt-get autoremove xorgxrdp -y 
sudo apt-get purge xorgxrdp -y
}

sh_credits()
{
echo
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m   ! Installation Completed...Please test your xRDP configuration   !\e[0m" 
/bin/echo -e "\e[1;36m   ! If Sound option selected, shutdown your machine completely     !\e[0m"
/bin/echo -e "\e[1;36m   ! start it again to have sound working as expected               !\e[0m"
/bin/echo -e "\e[1;36m   !                                                                !\e[0m"
/bin/echo -e "\e[1;36m   ! Credits : Written by Griffon - April 2020                      !\e[0m"
/bin/echo -e "\e[1;36m   !           www.c-nergy.be -xrdp-installer-v1.2.sh - ver 1.2     !\e[0m"
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
echo
}


#---------------------------------------------------#
# SECTION FOR OPTIMIZING CODE USAGE...              #
#---------------------------------------------------#

install_common()
{
allow_console
create_polkit
fix_theme
fix_ssl
fix_env
}

install_custom()
{
install_prereqs
get_binaries
compile_source
enable_service

}

#--------------------------------------------------------------------------#
# -----------------------END Function Section             -----------------#
#--------------------------------------------------------------------------#

#--------------------------------------------------------------------------#
#------------                 MAIN SCRIPT SECTION       -------------------# 
#--------------------------------------------------------------------------#

#---------------------------------------------------#
# Script Version information Displayed              #
#---------------------------------------------------#

echo
/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m   !   xrdp-installer-1.2 Script                                 !\e[0m"
/bin/echo -e "\e[1;36m   !   Support U16.04/18.04/19.10/20.04                          !\e[0m"
/bin/echo -e "\e[1;36m   !   Written by Griffon - April 2020 - www.c-nergy.be          !\e[0m"
/bin/echo -e "\e[1;36m   !                                                             !\e[0m"
/bin/echo -e "\e[1;36m   !   For Help and Syntax, type ./xrdp-installer-1.2.sh -h      !\e[0m"
/bin/echo -e "\e[1;36m   !                                                             !\e[0m"
/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
echo

#----------------------------------------------------------#
# Step 0 -Detecting if Parameters passed to script ....    #
#----------------------------------------------------------#
for arg in "$@"
do
    #Help Menu Requested
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
                echo "Usage Syntax and Examples"
                echo
                echo " --custom or -c           custom xRDP install (compilation from sources)"
				echo " --loginscreen or -l      customize xRDP login screen"
                echo " --remove or -r           removing xRDP packages"
                echo " --sound or -s            enable sound redirection in xRDP"
                echo
                echo "example                                                      "
                echo     
                echo " ./xrdp-installer-1.0.sh -c -s  custom install with sound redirection"
                echo " ./xrdp-installer-1.0.sh -l     standard install with custom login screen"
                echo " ./xrdp-installer-1.0.sh        standard install no additional features"
                echo
                exit
    fi
 
    if [ "$arg" == "--sound" ] || [ "$arg" == "-s" ]
    then
        fixSound="yes" 				
    fi 

    if [ "$arg" == "--loginscreen" ] || [ "$arg" == "-l" ]
    then
        fixlogin="yes"
    fi

    if [ "$arg" == "--custom" ] || [ "$arg" == "-c" ]
    then
        adv="yes"	
    fi

    if [ "$arg" == "--remove" ] || [ "$arg" == "-r" ]
    then
        removal="yes"		
    fi
done

#--------------------------------------------------------------------------------#
#-- Step 0 - Check that the script is run as normal user and not as root....
#-------------------------------------------------------------------------------#

if [[ $EUID -ne 0 ]]; then
	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;36m   !  Standard user detected....Proceeding....                   !\e[0m"
	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
else
	echo
	/bin/echo -e "\e[1;31m   !-------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;31m   !  Script launched with sudo command. Script will not run...  !\e[0m"
	/bin/echo -e "\e[1;31m   !  Run script a standard user account (no sudo). When needed  !\e[0m"
	/bin/echo -e "\e[1;31m   !  script will be prompted for password during execution      !\e[0m"
	/bin/echo -e "\e[1;31m   !                                                             !\e[0m"
	/bin/echo -e "\e[1;31m   !  Exiting Script - No Install Performed !!!                  !\e[0m"
	/bin/echo -e "\e[1;31m   !-------------------------------------------------------------!\e[0m"
	echo
	#sh_credits
	exit
fi

#---------------------------------------------------#
#-- Step 1 - Try to Detect Ubuntu Version....
#---------------------------------------------------#

version=$(lsb_release -sd)
codename=$(lsb_release -sc)

echo
/bin/echo -e "\e[1;33m   |-| Detecting Ubuntu version        \e[0m"
if  [[ "$version" = *"Ubuntu 16.04"* ]];
then
	/bin/echo -e "\e[1;32m       |-| Ubuntu Version : $version\e[0m"
	echo
elif  [[ "$version" = *"Ubuntu 18.04"* ]];
then
	/bin/echo -e "\e[1;32m       |-| Ubuntu Version : $version\e[0m"
	echo
elif [[ "$version" = *"Ubuntu 20.04"* ]];
then
	/bin/echo -e "\e[1;32m       |-| Ubuntu Version : $version\e[0m"
	echo
elif [[ "$version" = *"Ubuntu 19.10"* ]];
then
	/bin/echo -e "\e[1;32m       |-| Ubuntu Version : $version\e[0m"
	echo
else
	/bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;31m  ! Your system is not running a supported version               !\e[0m"
	/bin/echo -e "\e[1;31m  ! The script has been tested only on the following versions    !\e[0m"
	/bin/echo -e "\e[1;31m  ! U16.04.x/18.04.x/19.10/20.04.x                               !\e[0m"
	/bin/echo -e "\e[1;31m  ! The script is exiting...                                     !\e[0m"             
	/bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
	echo
	exit
fi

#-----------------------------------------------------------------------
#Step 2 - checking for additional Settings - xorg-xserver-core version
#----------------------------------------------------------------------

check_hwe

#--------------------------------------------------------------------------------#
#-- Step 3 - Check if Removal Option Selected
#--------------------------------------------------------------------------------#

if [ "$removal" = "yes" ];
then
	remove_xrdp
	echo
	sh_credits
	exit
fi


#---------------------------------------------------------#
# Step 4 - Executing the installation & config tasks .... #
#---------------------------------------------------------#

#-------------------------------------------------------------------
#- If Ubuntu 16.04 detected, we always perform a custom installation
#-------------------------------------------------------------------

#Check if script has run once...
if [ -f /etc/xrdp/xrdp-installer-check.log ]
then
echo
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m   ! INFO : xrdp-install script ran at least once on this computer. !\e[0m" 
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
else
if  [[ "$version" = *"Ubuntu 16.04"* ]];
then
	echo
	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;36m   !  Custom Installation for Ubuntu 16.04.x                     !\e[0m"
	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
	echo
	install_custom
	install_common
	
fi
 
#---------------------------------------------------------------------------------------
#- If custom option detected, additional check for U16.04 so skipped
#----------------------------------------------------------------------------------------

if  [[ "$version" != *"Ubuntu 16.04"* ]];
then
	if [ "$adv" = "yes" ];
	then
		echo
		/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
		/bin/echo -e "\e[1;36m   !  Custom Installation Option Selected.....                   !\e[0m"
		/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
		echo
		install_custom
		install_tweak
		install_common
		
	else
		echo
		/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
		/bin/echo -e "\e[1;36m   !  Standard Installation Mode Selected - U18.04 and later     !\e[0m"
		/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
		echo
		install_xrdp
		install_tweak
		install_common
		
	fi  #end if Adv option
fi  # end if version check not like U16.04
fi  # End check if file exists
#---------------------------------------------------------------------------------------
#- Check for Additional Options selected 
#----------------------------------------------------------------------------------------

if [ "$fixSound" = "yes" ]; 
then 
		enable_sound      
fi

if [ "$fixlogin" = "yes" ]; 
then
	echo
	custom_login
fi

#-----------------------------------------------------------------------
# Create Check file to see if script has run at least once...
#----------------------------------------------------------------------
#Create the log file 
sudo touch /etc/xrdp/xrdp-installer-check.log

#---------------------------------------------------------------------------------------
#- show Credits and finishing script
#--------------------------------------------------------------------------------------- 

sh_credits 
 
 
