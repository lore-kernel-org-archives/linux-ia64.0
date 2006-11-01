From: Len Brown <len.brown@intel.com>
Date: Wed, 01 Nov 2006 04:02:43 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <200610312302.43369.len.brown@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> > > http://www.kegel.com/crosstool/

I scribbled on demo-ia64.sh to build the latest:

--- demo-ia64.sh.orig   2006-10-31 22:50:46.000000000 -0500
+++ demo-ia64.sh        2006-10-31 22:50:29.000000000 -0500
@@ -18,6 +18,8 @@
 #eval `cat ia64.dat gcc-3.3.4-glibc-2.2.5.dat`        sh all.sh --notest   # fails
 #eval `cat ia64.dat gcc-3.4.0-glibc-2.3.2.dat`        sh all.sh --notest
 #eval `cat ia64.dat gcc-3.4.1-glibc-2.3.3.dat`        sh all.sh --notest
-eval `cat ia64.dat gcc-3.4.2-glibc-2.3.3.dat`        sh all.sh --notest
+#eval `cat ia64.dat gcc-3.4.2-glibc-2.3.3.dat`        sh all.sh --notest
+
+eval `cat ia64.dat gcc-4.1.0-glibc-2.3.6.dat`        sh all.sh --notest

 echo Done.


And updated the .dat file to use linux 2.6.18
(dunno what the 2.6.12.0 stuff is about)

--- gcc-4.1.0-glibc-2.3.6.dat.orig      2006-10-31 22:49:40.000000000 -0500
+++ gcc-4.1.0-glibc-2.3.6.dat   2006-10-31 22:01:53.000000000 -0500
@@ -2,7 +2,7 @@
 GCC_CORE_DIR=gcc-3.3.6
 GCC_DIR=gcc-4.1.0
 GLIBC_DIR=glibc-2.3.6
-LINUX_DIR=linux-2.6.15.4
+LINUX_DIR=linux-2.6.18
 LINUX_SANITIZED_HEADER_DIR=linux-libc-headers-2.6.12.0
 GLIBCTHREADS_FILENAME=glibc-linuxthreads-2.3.6
 GDB_DIR=gdb-6.4

built it, but it bombed out in the glibc:

$ sh demo-ia64.sh
....

/home/lenb/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-4.1.0-glibc-2.3.6/build-glibc/nscd/cache.o: In function `cache_add':
cache.c:(.text+0xf22): undefined reference to `__sync_bool_compare_and_swap_si'
cache.c:(.text+0xfe2): undefined reference to `__sync_fetch_and_add_si'
collect2: ld returned 1 exit status
make[2]: *** [/home/lenb/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-4.1.0-glibc-2.3.6/build-glibc/nscd/nscd] Error 1
make[2]: Leaving directory `/home/lenb/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-4.1.0-glibc-2.3.6/glibc-2.3.6/nscd'
make[1]: *** [nscd/others] Error 2
make[1]: Leaving directory `/home/lenb/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-4.1.0-glibc-2.3.6/glibc-2.3.6'
make: *** [all] Error 2

But apparently it got far enough to build a gcc for building IA64 kernels, because that works.

export ARCH=ia64
export CROSS_COMPILE=ia64-unknown-linux-gnu-
export PATH=$PATH:/opt/crosstool/gcc-4.1.0-glibc-2.3.6/ia64-unknown-linux-gnu/bin
MAKE="time make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE"
$MAKE -j4

thanks,
-Len

