#!/bin/bash

temp_path=$(dirname "$0")
cd $temp_path
real_path=$(pwd)
echo  "本脚本文件所在目录路径是: $real_path "
cd $real_path

yum -y install unzip bzip2-devel libtool libevent-devel libcap-devel openssl-devel
yum -y install bison flex snappy-devel numactl-devel cyrus-sasl-devel

mkdir -p /data/source/mcrouter/src

#GCC4.9 folly用到了诸如 chrono 之类的C++11库，必须使用GCC 4.8以上版本，才能够完整支持这些用到的C++11特性和标准库。
cd /data/source/mcrouter/src
#wget https://gmplib.org/download/gmp/gmp-5.1.3.tar.bz2
tar jxf gmp-5.1.3.tar.bz2 && cd gmp-5.1.3/
./configure && make && make install

cd /data/source/mcrouter/src
#wget http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.bz2
tar jxf mpfr-3.1.3.tar.bz2 ;cd mpfr-3.1.3/
./configure && make && make install

cd /data/source/mcrouter/src
#wget http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz
tar xzf mpc-1.0.1.tar.gz ;cd mpc-1.0.1
./configure && make && make install


export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:$LD_LIBRARY_PATH
#cd /data/source/mcrouter/src
#wget http://ftp.gnu.org/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2
#tar jxf gcc-4.9.1.tar.bz2 ;cd gcc-4.9.1
#ldconfig
#./configure -enable-threads=posix -disable-checking -disable-multilib -enable-languages=c,c++ -with-gmp -with-mpfr -with-mpc
#make && make install
#ldconfig


#CMAKE
cd /data/source/mcrouter/src
#wget http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
tar xvf cmake-2.8.12.2.tar.gz && cd cmake-2.8.12.2
./configure && make && make install


#AutoConf
cd /data/source/mcrouter/src
#wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar xvf autoconf-2.69.tar.gz && cd autoconf-2.69
./configure && make && make install


#SCONS
cd /data/source/mcrouter/src
#rpm -Uvh http://sourceforge.net/projects/scons/files/scons/2.3.3/scons-2.3.3-1.noarch.rpm
rpm -Uvh scons-2.3.3-1.noarch.rpm


#Ragel
cd /data/source/mcrouter/src
#wget http://www.colm.net/files/ragel/ragel-6.9.tar.gz
tar -zxvf ragel-6.9.tar.gz
cd ragel-6.9
./configure && make && make install


#Python27 for Boost
yum -y install centos-release-SCL
yum -y install python27
scl enable python27 "easy_install pip"


#Boost
scl enable python27 bash
python --version
cd /data/source/mcrouter/src
#wget http://downloads.sourceforge.net/boost/boost_1_56_0.tar.bz2
tar jxf boost_1_56_0.tar.bz2 && cd boost_1_56_0
./bootstrap.sh --prefix=/usr && ./b2 stage threading=multi link=shared
./b2 install threading=multi link=shared
ldconfig


#Gflags
cd /data/source/mcrouter/src
#wget https://github.com/schuhschuh/gflags/archive/v2.1.1.tar.gz
tar xzvf gflags-v2.1.1.tar.gz
mkdir -p gflags-2.1.1/build/ && cd gflags-2.1.1/build/
cmake .. -DBUILD_SHARED_LIBS:BOOL=ON -DGFLAGS_NAMESPACE:STRING=google && make && make install


#GLOG
cd /data/source/mcrouter/src
#wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
tar xvf glog-0.3.3.tar.gz && cd glog-0.3.3
./configure && make && make install


ln -s /usr/local/lib/libgmp.so.10 /usr/lib/libgmp.so.10
ln -s /usr/local/lib/libmpfr.so.4 /usr/lib/libmpfr.so.4
ln -s /usr/local/lib/libmpc.so.3 /usr/lib/libmpc.so.3

#double-conversion for Folly
cd /data/source/mcrouter/src
#git clone https://code.google.com/p/double-conversion/
cd double-conversion && scons install
ln -sf src double-conversion
ldconfig


#Folly
cd /data/source/mcrouter/src
#git clone https://github.com/genx7up/folly.git
#cd folly/folly/test
#wget https://googletest.googlecode.com/files/gtest-1.6.0.zip
#unzip gtest-1.6.0.zip
#cd ../
autoreconf --install
export CPPFLAGS="-I/data/source/mcrouter/src/double-conversion"
./configure && make && make install


#McRouter
cd /data/source/mcrouter/src
#git clone https://github.com/facebook/mcrouter.git
cd mcrouter/mcrouter
export CPPFLAGS="-I/data/source/mcrouter/src/double-conversion"
autoreconf --install
./configure && make && make install
mcrouter --help
