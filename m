From: Joe Griffin <joe.griffin@mscsoftware.com>
Date: Mon, 06 Nov 2000 19:34:23 +0000
Subject: [Linux-ia64] undefined reference to `__libc_start_main'
Message-Id: <marc-linux-ia64-105590678205660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I am getting the following message on my IA64 system:

/usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216-final/../../../crt1.o:
In function `_start':
/usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216-final/../../../crt1.o(.text+0x62):
undefined reference to `__libc_start_main'

If I compile a simple program, the error is not there.
However, if I link with a -L, -l, the error appears:


stpeter <60> cat simple.f
      PROGRAM MAINAL
      write(6,*) ' Hello world'
      end

stpeter <61>  /usr/bin/sgif90 -o simple simple.f

stpeter <62> simple
  Hello world

stpeter <63>  /usr/bin/sgif90 -o simple simple.f
-L/home/jjg/nast2001t2/obj -lnast
/usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216-final/../../../crt1.o:
In function `_start':
/usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216-final/../../../crt1.o(.text+0x62):
undefined reference to `__libc_start_main'
collect2: ld returned 1 exit status

Does anyone know how I can get around this error?

My system is:
stpeter <64> sgif90 -v
SGIcc Compilers: Version 0.01.0-10
stpeter <65> uname -a
Linux stpeter 2.4.0test8-000913-44smp #1 SMP Tue Oct 3 23:29:59 PDT 2000
ia64 unknown


I am not a subscriber (yet) to this group, so please
send comments to me directly.

Thanks,
Joe Griffin

