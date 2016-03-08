#/usr/bin/env bash

function tips()
{
  echo ""
  echo ""
  echo "---- Install Tips ----"
  echo "1. Install ARM Toolchain:  /root/compile-arm-toolchain.sh"
  echo "2. Install osmocom-core:   /root/compile-osmocom-core.sh"
  echo "3. Install osmocom-bb:     /root/compile-osmocom-bb.sh"
}

function update_sources_list()
{
  printf '%s' '
deb http://http.kali.org/kali sana main non-free contrib
deb http://security.kali.org/kali-security sana/updates main contrib non-free
deb-src http://http.kali.org/kali sana main non-free contrib
deb-src http://security.kali.org/kali-security sana/updates main contrib non-free
' | sudo tee /etc/apt/sources.list > /dev/null
}

function update_system()
{
  apt-get update && apt-get dist-upgrade -y 
}

function install_important_package()
{
  echo -e ":set number\n:syntax on" > /root/.vimrc
  sudo apt-get install -y build-essential libgmp3-dev libmpfr-dev libx11-6 libx11-dev texinfo flex bison libncurses5 libncurses5-dbg libncurses5-dev libncursesw5 libncursesw5-dbg libncursesw5-dev zlibc zlib1g-dev libmpfr4 libmpc-dev
  sudo apt-get install -y htop unzip bmon aptitude vim
  sudo aptitude install -y libtool shtool automake autoconf git-core pkg-config make gcc
  sudo apt-get install -y libpcsclite-dev libtalloc-dev
}

function set_gnu_arm_toolchain_script()
{
  printf '%s' '
#/usr/bin/env bash

function main() {
  install_gnu_arm_toolchain
  compile_and_arm_toolchain
}

function install_gnu_arm_toolchain()
{
  rm -rfv /root/armtoolchain
  mkdir /root/armtoolchain
  cd /root/armtoolchain
  mkdir build install src
  wget http://bb.osmocom.org/trac/raw-attachment/wiki/GnuArmToolchain/gnu-arm-build.3.sh
  chmod +x gnu-arm-build.3.sh
  cd /root/armtoolchain/src
  wget http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2
  wget http://ftp.gnu.org/gnu/binutils/binutils-2.21.1a.tar.bz2
  wget ftp://sources.redhat.com/pub/newlib/newlib-1.19.0.tar.gz
}

function compile_and_arm_toolchain()
{
  cd /root/armtoolchain
  echo "Yes" | ./gnu-arm-build.3.sh
  echo "export PATH=$PATH:/root/armtoolchain/install/bin" >> /root/.bashrc
  source /root/.bashrc
}

main
' | sudo tee /root/compile-arm-toolchain.sh > /dev/null
  chmod +x /root/compile-arm-toolchain.sh
}

function set_libosmocore_script()
{
  printf '%s' '
#/usr/bin/env bash

function main() {
  compile_libosmocore
}

function compile_libosmocore()
{
  cd /root/armtoolchain/
  rm -rfv /root/armtoolchain/libosmocore
  git clone git://git.osmocom.org/libosmocore.git
  cd /root/armtoolchain/libosmocore
  autoreconf -i
  ./configure
  make
  sudo make install
  sudo ldconfig -i
  cd /root/
}

main
' | sudo tee /root/compile-osmocom-core.sh > /dev/null
  chmod +x /root/compile-osmocom-core.sh
}


function set_osmocom_bb_script()
{
  printf '%s' '
#/usr/bin/env bash

function main() {
  export PATH=$PATH:/root/armtoolchain/install/bin
  compile_osmocom_bb
}

function compile_osmocom_bb()
{
  cd /root/armtoolchain/
  rm -rfv /root/armtoolchain/osmocom-bb
  git clone git://git.osmocom.org/osmocom-bb.git
  cd /root/armtoolchain/osmocom-bb
  git pull --rebase
  cd /root/armtoolchain/osmocom-bb/src
  make
  cd /root/
}

main
' | sudo tee /root/compile-osmocom-bb.sh > /dev/null
  chmod +x /root/compile-osmocom-bb.sh
}


function main()
{
  update_sources_list
  update_system
  install_important_package
  set_gnu_arm_toolchain_script
  set_libosmocore_script
  set_osmocom_bb_script
  tips
}

main