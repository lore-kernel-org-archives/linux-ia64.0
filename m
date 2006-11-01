From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Nov 2006 15:26:39 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <Pine.LNX.4.64.0611010724230.12414@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 1 Nov 2006, Andreas Schwab wrote:

> glibc 2.3.6 is about a year old and predates gcc 4.1.0 by 3 months. You
> should really use a more recent glibc.

I tried debians toolchain-source before and it also fails.

Just tried to download crosstool-0.42. It seems to build glibc-2.3.3(?) 
and it fails to build glibc with

 GCC_SYSROOT_ARG_CORE=--without-headers
+ 
GCC_SYSROOT_ARG=--with-headers=/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu/ia64-unknown-linux-gnu/include
+ GLIBC_SYSROOT_ARG=prefix+ mkdir -p 
/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu/ia64-unknown-linux-gnu/lib
+ mkdir -p 
/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu/ia64-unknown-linux-gnu/usr/lib
+ echo

+ echo 'Building for --target=ia64-unknown-linux-gnu, 
--prefix=/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu'
Building for --target=ia64-unknown-linux-gnu, 
--prefix=/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu
+ test -z ''
+ echo Prepare kernel headers
Prepare kernel headers
+ cd 
/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/linux-2.6.8
+ mkdir -p 
/opt/crosstool/gcc-3.4.2-glibc-2.3.3/ia64-unknown-linux-gnu/ia64-unknown-linux-gnu/include
+ test -z ''
+ test -f /home/christoph/explore/crosstool-0.42/ia64.config
+ cp /home/christoph/explore/crosstool-0.42/ia64.config .config
+ test -f .config
+ yes ''
+ make ARCH=ia64 oldconfig
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/basic/split-include
  HOSTCC  scripts/basic/docproc
  SHIPPED scripts/kconfig/zconf.tab.h
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/mconf.o
scripts/kconfig/mconf.c:91: error: static declaration of 'current_menu' 
follows non-static declaration
scripts/kconfig/lkc.h:63: error: previous declaration of 'current_menu' 
was here
make[1]: *** [scripts/kconfig/mconf.o] Error 1
make: *** [oldconfig] Error 2

