From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Fri, 30 Nov 2001 18:59:33 +0000
Subject: [Linux-ia64] pthread lib setting for ia64?
Message-Id: <marc-linux-ia64-105590698805566@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi 
While running my program on a Linux machine (turbo linux) Itanium processor,
the program does a segmentation fault on a pthread_create(..) command. I
checked the arguments of the pthread_create(...) and there is no problem
with them. So I ran the program thru gdb , and got the following on seg
fault:

Starting
program:
/fxsvrux001/home1/depereir/Tmk_SMP-26/apps/test_C/bin.ia64_linux2/stress.udp
-- -n2 -N1 -hcopilot{,} -p5001 -i1
Tmk_startup: SWAPDIR=(null), putting swap file in "/tmp".

Program received signal SIG32, Real-time event 32.
0x2000000000217ba2 in rt_sigsuspend () from /lib/libc.so.6.1
(gdb) where 
#0  0x2000000000217ba2 in rt_sigsuspend () from /lib/libc.so.6.1
#1  0x20000000000dc8c0 in sigsuspend () from /lib/libc.so.6.1
#2  0x2000000000052f70 in __pthread_wait_for_restart_signal ()
   from /lib/libpthread.so.0
#3  0x2000000000052280 in pthread_create@@GLIBC_2.2 ()
   from /lib/libpthread.so.0
#4  0x4000000000017b50 in Tmk_sigio_create_thread (
    start_routine=0x4000000000022e50 <_fini+17456>,
args=0x60000000016cdec8, 
    callerName=0x4000000000020990 "Tmk_sigio_initialize") at
../src/sigio.c:364
#5  0x4000000000017dc0 in Tmk_sigio_initialize () at ../src/sigio.c:396
#6  0x400000000001b8f0 in Tmk_startup (argc=8, argv=0x80000ffffffff838)
    at ../src/startup.c:932
#7  0x4000000000003bc0 in main (argc=8, argv=0x80000ffffffff838)
    at ../src/stress.c:163
(gdb) 


the program receives a SIG32 signal from rt_sigsuspend(..) .I am unable to
figure this out. 
Is there some setting for pthread library that has to be done before running
on itanium? some patch or something that I am missing?? is there some stack
size to be set??
Please let me know.

thanks
D'laila 


