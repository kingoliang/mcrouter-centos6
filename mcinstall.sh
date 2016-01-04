#!/bin/bash
## install dependency

if [ ! -f "epel-release-latest-6.noarch.rpm" ]
  then
  wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
fi

pwd=`dirname $0`
rpm -Uvh epel-release-latest-6.noarch.rpm

yum install -y bzip2-devel  libevent-devel libcap-devel scons rpm-build
yum install -y jemalloc-devel gmp-devel mpfr-devel libmpc-devel m4 wget
yum install -y python-devel bzip2-devel 
yum install -y m4 cmake libicu-devel chrpath openmpi-devel
yum install -y mpich-devel openssl-devel
yum install -y glibc-devel.i686 glibc-devel.x86_64 gcc gcc-c++ zlib-devel
yum install -y gmp-devel mpfr-devel libmpc-devel
yum install -y gflags-devel

#gflags-1.3-7.el6.x86_64
#gmp-4.3.1-7.el6_2.2.x86_64
#libmpc-0.8-3.el6.x86_64
#mpfr-2.4.1-6.el6.x86_64

cd /usr/local/src

if [ ! -f "/usr/local/lib/libglog.so" ] ; then
  #glog-0.3.3 rpmbuild
  if [ ! -f "glog-0.3.3.tar.gz" ]
    then
    if [ -f "$pwd/resources/glog-0.3.3.tar.gz" ]
        then
            echo "CP ................"
            cp resources/glog-0.3.3.tar.gz /usr/local/src
        else
            echo "WGET ................"
            wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
    fi
  fi

  #rpmbuild -tb -D'NAME glog' -D'VERSION 0.3.3' glog-0.3.3.tar.gz
  tar zxvf glog-0.3.3.tar.gz
  cd glog-0.3.3
  ./configure && make && make install
  if [ $? -eq 0 ] ; then  echo "glog build success"; else echo "glog build error" ; exit; fi
fi
#yum install -y ~/rpmbuild/RPMS/x86_64/glog-0.3.3-1.x86_64.rpm  ~/rpmbuild/RPMS/x86_64/glog-devel-0.3.3-1.x86_64.rpm


cd /usr/local/src
if [ ! -f "libtool-2.4.4.tar.gz" ]
  then
  wget http://ftpmirror.gnu.org/libtool/libtool-2.4.4.tar.gz
fi

if [ ! -f "autoconf-2.69.tar.gz" ]
  then
  wget http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz
fi

if [ ! -f "automake-1.13.tar.gz" ]
  then
  wget http://ftpmirror.gnu.org/automake/automake-1.13.tar.gz
fi

if [ ! -f "ragel-6.9.tar.gz" ]
  then
  wget http://www.colm.net/files/ragel/ragel-6.9.tar.gz
fi

export PATH=/opt/autotools/bin:$PATH

/usr/local/bin/ragel --version | grep 6.9
if [ $? -ne 0 ] ; then
    tar xvzf ragel-6.9.tar.gz && cd ragel-6.9
    ./configure && make && make install
    if [ $? -eq 0 ] ; then  echo "build ragel success"; else echo $? ; exit; fi
fi
cd /usr/local/src

/opt/autotools/bin/autoconf --version| grep 2.69
if [ $? -ne 0 ] ; then
  tar xvzf autoconf-2.69.tar.gz && cd autoconf-2.69
  ./configure --prefix=/opt/autotools && make && sudo make install
  if [ $? -eq 0 ] ; then  echo "autoconf build success"; else echo $? ; exit; fi
fi

cd /usr/local/src
/opt/autotools/bin/automake --version| grep 1.13
if [ $? -ne 0 ] ; then
  tar xvzf automake-1.13.tar.gz && cd automake-1.13
  ./configure --prefix=/opt/autotools && make && sudo make install
  if [ $? -eq 0 ] ; then  echo "automake build success"; else echo $? ; exit; fi
fi

cd /usr/local/src
/opt/autotools/bin/libtool --version| grep 2.4.4
if [ $? -ne 0 ] ; then
  tar xvzf libtool-2.4.4.tar.gz && cd libtool-2.4.4
  ./configure --prefix=/opt/autotools && make && sudo make install
  if [ $? -eq 0 ] ; then  echo "autotools build success"; else echo $? ; exit; fi
fi

/opt/gcc/bin/gcc --version | grep 4.8.4
if [ $? -ne 0 ] ; then
  echo "install gcc 4.8.4"
  cd /usr/local/src
  #gcc-4.8.4
  if [ ! -f "gcc-4.8.4.tar.bz2" ]
    then
    wget http://ftpmirror.gnu.org/gcc/gcc-4.8.4/gcc-4.8.4.tar.bz2
  fi

  tar xvjf gcc-4.8.4.tar.bz2
  cd gcc-4.8.4
  mkdir obj
  cd obj
  ../configure --prefix=/opt/gcc --enable-bootstrap --disable-shared --enable-static --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-languages=c,c++ --disable-dssi --with-ppl --with-cloog --with-tune=generic --build=x86_64-redhat-linux --with-gmp --with-mpfr --with-mpc  --with-arch_32=i686
  make && sudo make install
  if [ $? -eq 0 ] ; then  echo "gcc build success"; else echo $? ; exit; fi
fi

export PATH=/opt/autotools/bin:$PATH
export PATH=/opt/gcc/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/lib:/lib64
ldconfig

#boost 1.55
cd /usr/local/src
cat /usr/local/include/boost/version.hpp | grep BOOST_LIB_VERSION| grep 1_55
if [ $? -ne 0 ] ; then
  if [ ! -f "boost_1_55_0.tar.gz" ]
    then
    wget http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.gz
  fi

  tar xvzf boost_1_55_0.tar.gz
  cd boost_1_55_0
  ./bootstrap.sh
  ./b2 architecture=x86 address-model=64 link=static
  ./bjam architecture=x86 address-model=64 link=static install
  if [ $? -eq 0 ] ; then  echo "boostrap build sucess"; else echo "boostrap build error" ; exit; fi
  ldconfig
fi

cd /usr/local/src
strings /usr/local/lib/libdouble-conversion.a | grep 2.0.1
if [ $? -ne 0 ] ; then
  # double-conversion
  if [ ! -f "double-conversion.zip" ]
    then
    #wget -O double-conversion.zip https://github.com/floitsch/double-conversion/archive/master.zip
    wget -O double-conversion.zip https://codeload.github.com/google/double-conversion/zip/v2.0.1
  fi

  unzip double-conversion.zip
  cd double-conversion-2.0.1
  cmake . && make && sudo make install
  if [ $? -eq 0 ] ; then  echo "0"; else echo "double-conversion build err" ; exit; fi
  ldconfig
fi

#folly 0.57.0
cd /usr/local/src
if [ ! -f "folly-master.zip" ]
  then
  #git clone https://github.com/facebook/folly
        #wget -O folly-0.57.0.zip https://codeload.github.com/facebook/folly/zip/v0.57.0
        wget -O folly-master.zip https://codeload.github.com/facebook/folly/zip/master
        wget -O folly-master.zip https://codeload.github.com/kingoliang/folly/zip/master
fi

unzip folly-master.zip
cd folly-master/folly
sed '/Checks for library functions/ iAC_CHECK_LIB([pthread], [pthread_create])\n' configure.ac > configure.ac.new
autoreconf -ivf
./configure --disable-shared --enable-static && make && make install
if [ $? -eq 0 ] ; then  echo "0"; else echo "folly build error" ; exit; fi
ldconfig


#mcrouter
cd /usr/local/src
if [ ! -f "mcrouter-master.zip" ]
  then
  #wget -O mcrouter-9.14.0.zip https://codeload.github.com/facebook/mcrouter/zip/v0.13.0
  wget -O mcrouter-master.zip https://codeload.github.com/kingoliang/mcrouter/zip/master
fi
unzip mcrouter-master.zip
cd mcrouter-master/mcrouter
autoreconf -ivf
./configure && make && make install
if [ $? -eq 0 ] ; then  echo "0"; else echo "mcrouter build error" ; exit; fi
mcrouter --help
