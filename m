From: navin <navin@students.iiit.net>
Date: Wed, 07 May 2003 16:15:11 +0000
Subject: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	I am doing a project on compilers.I have to build gcc for ia64.I 
did build the binutils .In that case i didn't get any compilation errors.

HOSTMACHINE=i386 pentium
TARGETMACHINE=ia64

 Next i had to build gcc (source gcc-3.2) for ia64. I configured 
it with the following option 
CFLAGS="-O2 -Dinhibit_libc" ../gcc-3.2/configure 
--target=ia64-unknown-linux --prefix=/FPS/Bunny/work/ia64.bak 
--enable-languages=c --disable-shared --disable-multilib 
--enable-threads=single --without-headers
and with a lot of other options like removing the --without-headers part 
and another time adding other options with-headers=asm-ia64 (kernel 
sources) . Every time i get  error saying 

if [ -f stmp-dirs ]; then true; else touch stmp-dirs; fi
/FPS/Bunny/work/gcc-build3/gcc/xgcc -B/FPS/Bunny/work/gcc-build3/gcc/ 
-B/FPS/Bun 
ny/work/ia64.bak/ia64-unknown-linux/bin/ 
-B/FPS/Bunny/work/ia64.bak/ia64-unknown 
-linux/lib/ -isystem /FPS/Bunny/work/ia64.bak/ia64-unknown-linux/include 
-O2  -D 
IN_GCC -DCROSS_COMPILE   -W -Wall -Wwrite-strings -Wstrict-prototypes 
-Wmissing- 
prototypes -isystem ./include  -fPIC -g  -DIN_LIBGCC2 
-D__GCC_FLOAT_NOT_NEEDED   
-I. -I. -I../../gcc-3.2/gcc -I../../gcc-3.2/gcc/. 
-I../../gcc-3.2/gcc/config -I. 
./../gcc-3.2/gcc/../include  -DL_muldi3 -c ../../gcc-3.2/gcc/libgcc2.c -o 
libgcc 
/./_muldi3.o
In file included from tconfig.h:21,
                 from ../../gcc-3.2/gcc/libgcc2.c:36:
../../gcc-3.2/gcc/config/ia64/linux.h:58:26: sys/ucontext.h: No such file 
or dir 
ectory
In file included from ../../gcc-3.2/gcc/libgcc2.c:37:
../../gcc-3.2/gcc/tsystem.h:63:19: stdio.h: No such file or directory
../../gcc-3.2/gcc/tsystem.h:66:23: sys/types.h: No such file or directory
In file included from 
/FPS/Bunny/work/ia64.bak/ia64-unknown-linux/sys-include/st 
ring.h:12,
                 from ../../gcc-3.2/gcc/tsystem.h:76,
                 from ../../gcc-3.2/gcc/libgcc2.c:37:
/FPS/Bunny/work/ia64.bak/ia64-unknown-linux/include/linux/config.h:4:28: 
linux/a 
utoconf.h: No such file or directory
In file included from ../../gcc-3.2/gcc/libgcc2.c:37:
../../gcc-3.2/gcc/tsystem.h:80:20: stdlib.h: No such file or directory
In file included from 
/FPS/Bunny/work/ia64.bak/ia64-unknown-linux/lib/include/li 
mits.h:117,
                 from /FPS/Bunny/work/gcc-build3/gcc/include/limits.h:132,
                 from 
/FPS/Bunny/work/gcc-build3/gcc/include/syslimits.h:7,
                 from /FPS/Bunny/work/gcc-build3/gcc/include/limits.h:11,
                 from ../../gcc-3.2/gcc/tsystem.h:84,
                 from ../../gcc-3.2/gcc/libgcc2.c:37:
/FPS/Bunny/work/ia64.bak/ia64-unknown-linux/sys-include/limits.h:117:75: 
no incl 
ude path in which to find limits.h
In file included from ../../gcc-3.2/gcc/libgcc2.c:37:
../../gcc-3.2/gcc/tsystem.h:87:18: time.h: No such file or directory
make[2]: *** [libgcc/./_muldi3.o] Error 1
make[2]: Leaving directory `/FPS/Bunny/work/gcc-build3/gcc'
make[1]: *** [libgcc.a] Error 2
make[1]: Leaving directory `/FPS/Bunny/work/gcc-build3/gcc'

I also referred to many cross GCC faq and howto's but no help .The error 
still pops up.

Also from some of the previous posts i found that if i am building on a 
pentium or some other machine there is a trick involved.Andreas Jaegar 
told me that i had to install-headers before compiling the bootstrap 
gcc.He said to contact you guys as i don't have the headers for ia64.I 
have the sources for kernel which contain asm-ia64 and glibc-2.3.I don't 
know how to avoid the error.


Thank You 

Nevin


