From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 21 Mar 2002 02:30:47 +0000
Subject: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a couple of questions about cross compiling with gcc 3.0:

1) is it possible to build an x86 hosted gcc 3.0 ia64 cross compiler
   without nue?  Or, which packages do I need to build a gcc cross
   compiler?
2) does an x86 hosted gcc 3.0 ia64 cross compiler generate different
   code than a native ia64 compiler?  If so, how different is the
   generated code?

I'd like to have a gcc 3.0 cross compiler for the purpose of building
kernels unless the cross compiler generated code differs enough from a
natively built that I'm likely to run into bugs that I wouldn't
otherwise.

In trying to do (1) to answer (2) for myself, I did the following on a
Red Hat 6.2 x86 machine w/gcc-2.96 from 7.0 installed
a) built and installed binutils 2.12 (configured with
   --target=ia64-gnu-linux --prefix=/tmp/ia64-cross-3.0)
b) tried to build and install gcc 3.0 (configured with the same options
   as above), but with 'make LANGUAGES=c' instead of just 'make'

Unfortunately, I got hung up in the middle of step (b) with the errors
shown below.  IIRC, the Cygnus snapshot tarballs were 'cross-compile
ready' in that they had all the necessary header files and utilities
needed for a full cross development environment.  Any notes on how
those trees were built would be appreciated.

Thanks,
Jesse

/home/jbarnes/working/cross/gcc-build/gcc/xgcc -B/home/jbarnes/working/cross/gcc-build/gcc/ -B/tmp/ia64-cross-3.0/ia64-gnu-linux/bin/ -B/tmp/ia64-cross-3.0/ia64-gnu-linux/lib/ -isystem /tmp/ia64-cross-3.0/ia64-gnu-linux/include -O2  -DCROSS_COMPILE -DIN_GCC    -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -isystem ./include  -fPIC -g1  -DIN_LIBGCC2 -D__GCC_FLOAT_NOT_NEEDED -Dinhibit_libc -I. -I. -I../../gcc-3.0/gcc -I../../gcc-3.0/gcc/. -I../../gcc-3.0/gcc/config -I../../gcc-3.0/gcc/../include -fexceptions -c ../../gcc-3.0/gcc/config/ia64/unwind-ia64.c -o libgcc/./unwind-ia64.o
In file included from ../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:35:
../../gcc-3.0/gcc/unwind.h:169:20: stdlib.h: No such file or directory
In file included from ../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:35:
../../gcc-3.0/gcc/unwind.h: In function `_Unwind_GetTextRelBase':
../../gcc-3.0/gcc/unwind.h:181: warning: implicit declaration of function `abort'
../../gcc-3.0/gcc/unwind.h:179: warning: unused parameter `_C'
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c: In function `push':
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:234: warning: implicit declaration of function `memcpy'
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c: In function `uw_frame_state_for':
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:1462: warning: implicit declaration of function `memset'
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c: In function `uw_install_context':
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:1777: warning: passing arg 1 of `ia64_rse_skip_regs' makes pointer from integer without a cast
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:1777: warning: assignment makes integer from pointer without a cast
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c: At top level:
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:1264: warning: `ia64_rse_is_rnat_slot' defined but not used
../../gcc-3.0/gcc/config/ia64/unwind-ia64.c:1281: warning: `ia64_rse_num_regs' defined but not used
make[2]: *** [libgcc/./unwind-ia64.o] Error 1
make[2]: Leaving directory `/home/jbarnes/working/cross/gcc-build/gcc'
make[1]: *** [libgcc.a] Error 2
make[1]: Leaving directory `/home/jbarnes/working/cross/gcc-build/gcc'
make: *** [all-gcc] Error 2

