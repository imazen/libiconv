#!/bin/bash
# set $1 to 1 to force an x86 build

_build()
{
  echo "*building* (x86=${1-0})"
  
  pack="*.a *.so*"
  CFLAGS="-fPIC"
  [ ${1-0} -gt 0 ] && CFLAGS="$CFLAGS -m32"
  
  cd source
  chmod 777 -R tests
  export CFLAGS
  sh ./configure --enable-static
  make
  make check
  cd lib/.libs
  objdump -f *.so | grep ^architecture
  ldd *.so
  find . -maxdepth 1 -type l -exec rm -f {} \;
  tar -zcf binaries.tar.gz $pack
  mv binaries.tar.gz ../../..
  cd ../../..
}


_clean()
{
  echo "*cleaning*"
  git clean -ffde /out > /dev/null
  git reset --hard > /dev/null
}

mkdir out

_build
mv binaries.tar.gz out/libiconv-x64.tar.gz
_clean

sudo apt-get -y update > /dev/null
sudo apt-get -y install gcc-multilib > /dev/null

_build 1
mv binaries.tar.gz out/libiconv-x86.tar.gz
_clean
