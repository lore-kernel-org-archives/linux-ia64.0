From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 05 Oct 2000 16:55:30 +0000
Subject: [Linux-ia64] Error compiling c++ support with glibc 2.2
Message-Id: <marc-linux-ia64-105590678205544@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm getting the following error when trying to compile the 0925 gnupro on
glibc 2.2(From 10/02 CVS):

/usr/src/turbo/BUILD/gnupro-2.96/build/gcc/g++ -B/usr/src/turbo/BUILD/gnupro-2.96/build/gcc/ -B/usr/ia64-cygnus-linux/bin/ -L/usr/src/turbo/BUILD/gnupro-2.96/build/ia64-cygnus-linux/libstdc++ -c -g -O2 -fvtable-thunks -D_GNU_SOURCE -fno-implicit-templates -I. -I../../../src/libio -nostdinc++ -D_IO_MTSAFE_IO ../../../src/libio/isgetline.cc
../../../src/libio/iostream.cc: In method `istream &istream::get (char 
&)':
./../../src/libio/iostream.cc:75: `_IO_USER_LOCK' undeclared (first 
use this function)
../../../src/libio/iostream.cc:75: (Each undeclared identifier is 
reported only once for each function it appears in.)
../../../src/libio/isgetline.cc: In method `istream &istream::getline 
(char *, int, char)':
../../../src/libio/isgetline.cc:41: `_IO_USER_LOCK' undeclared (first 
use this function)
../../../src/libio/isgetline.cc:41: (Each undeclared identifier is 
reported only once for each function it appears in.)
make[1]: *** [isgetline.o] Error 1
make[1]: *** Waiting for unfinished jobs....
make[1]: *** [iostream.o] Error 1
make[1]: Leaving directory `/usr/src/turbo/BUILD/gnupro-2.96/build/ia64-cygnus-linux/libio'
make: *** [all-target-libio] Error 2
Bad exit status from /var/tmp/rpm-tmp.11588 (%build)


According to Jim Wilson, iostream.cc is including
/usr/include/bits/stdio-lock.h which references _IO_USER_LOCK.  However,
_IO_USER_LOCK is defined in /usr/include/libio.h which is not being
included.  Has anyone else run accross this problem?  Any solutions?

Thanks

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

