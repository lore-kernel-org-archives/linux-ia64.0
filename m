From: Martin Pool <mbp@samba.org>
Date: Mon, 28 Apr 2003 07:10:49 +0000
Subject: Re: [Linux-ia64] building an ia64 cross toolchain on debian?
Message-Id: <marc-linux-ia64-105590723705614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got a binutils package built and installed, 

/home/mbp/work/toolchain-ia64-debian/gcc-ia64-unknown-linux-3.2.3.cvs20030221/build/gcc/xgcc -B/home/mbp/work/toolchain-ia64-debian/gcc-ia64-unknown-linux-3.2.3.cvs20030221/build/gcc/ -B/usr/ia64-unknown-linux/bin/ -B/usr/ia64-unknown-linux/lib/ -isystem /usr/ia64-unknown-linux/include -O2  -DIN_GCC -DCROSS_COMPILE   -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -isystem ./include  -fPIC -g -DHAVE_GTHR_DEFAULT -DIN_LIBGCC2 -D__GCC_FLOAT_NOT_NEEDED -Dinhibit_libc -I. -I. -I../../src/gcc -I../../src/gcc/. -I../../src/gcc/config -I../../src/gcc/../include  -DL_muldi3 -c ../../src/gcc/libgcc2.c -o libgcc/./_muldi3.o
In file included from tconfig.h:21,
                 from ../../src/gcc/libgcc2.c:36:
../../src/gcc/config/ia64/linux.h:57:20: signal.h: No such file or directory
../../src/gcc/config/ia64/linux.h:58:26: sys/ucontext.h: No such file or directory
make[3]: *** [libgcc/./_muldi3.o] Error 1
make[3]: Leaving directory `/home/mbp/work/toolchain-ia64-debian/gcc-ia64-unknown-linux-3.2.3.cvs20030221/build/gcc'

There seems to be a problem that the cross libc produced by
"tpkg-install-libc ia64-unknown-linx" wants to install into
/usr/ia64-linux (sic) whereas the binutils install into
/usr/ia64-unknown-linux.  I think this was causing gcc to be unable to
find the header files.

I kludged this up by just symlinking the two together but it seems
like there ought to be a better way.

Anyhow, now I seem to have a working cross toolchain, which is great.

-- 
Martin 

