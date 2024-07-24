#!/usr/bin/env bash
set -eu

#---------- STYLES ----------#

# Colors
  BG_BLUE="\e[44m"
  BG_GREEN="\e[42m"
  BG_RED="\e[41m"

# Format
  FONT_BOLD="\e[1m"

# Reset
  RESET_STYLE="\e[0m"

# States
  FAILURE="${FONT_BOLD}${BG_RED} FAILURE ${RESET_STYLE}"
  MESSAGE="${FONT_BOLD}${BG_BLUE} MESSAGE ${RESET_STYLE}"
  SUCCESS="${FONT_BOLD}${BG_GREEN} SUCCESS ${RESET_STYLE}"

#---------- FUNCTIONS ----------#

apt_update() {
  sudo apt-get update -y
}

apt_dist_upgrade() {
  apt_update && sudo apt-get dist-upgrade -y
}

check_network_connection() {
  echo -e "\n${MESSAGE} Checking network connection..."

  if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
    echo -e "${FAILURE} Couldn't retrieve network connection\n"
    exit 1
  else
    echo -e "${SUCCESS} Network connection was established\n"
  fi
}

enable_32bit_softwares() {
  sudo dpkg --add-architecture i386
}

unlock_apt() {
  LOCK_PATHS=(
    "/var/lib/dpkg/lock-frontend"
    "/var/cache/apt/archives/lock"
  )

  for path in ${LOCK_PATHS[@]}; do
    if [ -e $path ]; then
      sudo rm "$path"
    fi
  done
}

install_packages_apt() {
  echo -e "\n${MESSAGE} Installing aptitude packages..."

  PACKAGES_APT=(
    folder-color
    gnome-sushi
    gufw
    snapd
    spice-vdagen
    timeshift
    virt-manager
  )

  for package in ${PACKAGES_APT[@]}; do
    if ! dpkg --list | grep --silent $package; then
      sudo apt-get install "$package" -y
    else
      echo -e "${SUCCESS} '$package' is already installed"
    fi
  done
}

install_packages_flatpak() {
  echo -e "\n${MESSAGE} Installing flatpak packages..."

  PACKAGES_FLATPAK=(
    com.discordapp.Discord
    com.google.Chrome
    com.spotify.Client
    com.visualstudio.code
    io.github.pwr_solaar.solaar
    org.flameshot.Flameshot
    org.localsend.localsend_app
    org.qbittorrent.qBittorrent
    org.videolan.VLC
  )

  for package in ${PACKAGES_FLATPAK[@]}; do
    if ! flatpak list | grep --silent $package; then
      flatpak install flathub "$package" -y
    else
      echo -e "${SUCCESS} '$package' is already installed"
    fi
  done
}

install_packages_snap() {
  echo -e "\n${MESSAGE} Installing snap packages..."

  PACKAGES_SNAP=(
    mockoon
  )

  for package in ${PACKAGES_SNAP[@]}; do
    if ! snap list | grep --silent $package; then # NOT FOUND
      sudo snap install "$package"
    else
      echo -e "${SUCCESS} '$package' is already installed"
    fi
  done
}

system_clean() {
  apt_update
  sudo flatpak update
  # sudo snap refresh # @FIX_ME: snapd fails to install
  sudo apt-get autoclean
  sudo apt-get autoremove -y
}

reboot() {
  echo -e "\n${SUCCESS} The script was executed successfully"
  echo -e "${MESSAGE} Rebooting system in 5 seconds..."
  sleep 5
  sudo shutdown -r now
}

#---------- EXECUTING ----------#

unlock_apt
check_network_connection
unlock_apt
apt_dist_upgrade
unlock_apt
enable_32bit_softwares
apt_update
install_packages_apt
install_packages_flatpak
# install_packages_snap # @FIX_ME: snapd fails to install
apt_dist_upgrade
system_clean
reboot
