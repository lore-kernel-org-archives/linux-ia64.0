From: "MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com>
Date: Tue, 13 May 2003 20:06:41 +0000
Subject: [Linux-ia64] libc umount and umount2 can't both be right
Message-Id: <marc-linux-ia64-105590723705762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The problem:  On IA64, the implementation of umount(2) in glibc
and of sys_umount in the kernel results in the kernel performing
umounts with essentially random flag words.

$ dpkg -l | grep libc6
ii libc6.1       2.3.1-17  GNU C Library: Shared libraries and Timezone
ii libc6.1-dev   2.3.1-17  GNU C Library: Development Libraries and Hea

In libc, umount and umount2 are the same code.  They both use
syscall number 1044 without introducing a call layer. 
   
$ gdb /lib/libc.so.6.1
...
(gdb) disas umount
Dump of assembler code for function umount:
0x1a63a0 <umount>:      [MII]       mov r1544
0x1a63a1 <umount+1>:                break.i 0x100000;;
0x1a63a2 <umount+2>:                cmp.eq p6,p0=-1,r10;;
0x1a63b0 <umount+16>:
    [BBB] (p06) br.cond.spnt.few 0x2d820 <__libc_start_main+640>
0x1a63b1 <umount+17>:               br.ret.sptk.few b0
0x1a63b2 <umount+18>:               nop.b 0x0;;
End of assembler dump.

(gdb) disas umount2
Dump of assembler code for function umount2:
0x1a63c0 <umount2>:     [MII]       mov r1544
0x1a63c1 <umount2+1>:               break.i 0x100000;;
0x1a63c2 <umount2+2>:               cmp.eq p6,p0=-1,r10;;
0x1a63d0 <umount2+16>:
    [BBB] (p06) br.cond.spnt.few 0x2d820 <__libc_start_main+640>
0x1a63d1 <umount2+17>:              br.ret.sptk.few b0
0x1a63d2 <umount2+18>:              nop.b 0x0;;
End of assembler dump.


And from fs/namespace.c, the interface for sys_umount is:

   asmlinkage long sys_umount(char * name, int flags)

The problem is that sys_umount expects two parameters, the sys/umount.h
header only allows the program to specify one parameter for umount(),
and the kernel picks up whatever is in the next output register of the
caller as the flags word.  So umount calls are executed with essentially
random flag words.

The problem could be solved in libc by implementing a wrapper for
umount that looks something like:

extern int umount2 (__const char *__special_file, int __flags) ;

int umount (const char *target)
{
	umount2(target, 0);
}

In this case, umount2 could use the same lightweight method that
it uses now.  

Bob Montgomery, HP

