From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 19 Sep 2003 16:32:18 +0000
Subject: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106398916511816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The inline ia64 system call assumes all values passed to kernel are
signed 64bit. It does sign extension if the incoming arg is not signed
64bit. In case of fxstat.c:

int
__fxstat (int vers, int fd, struct stat *buf)
{
  return INLINE_SYSCALL (fstat, 2, fd, CHECK_1 (buf));
}
=20
it leads to

0000000000000000 <__fxstat>:
   0:   00 20 39 0c 80 05       [MII]       alloc r36=3Dar.pfs,14,6,0
   6:   f0 e0 01 12 48 a0                   mov r15=1212
   c:   04 08 00 84                         mov r37=3Dr1
  10:   01 38 01 44 00 21       [MII]       mov r39=3Dr34
  16:   60 02 84 2c 00 60                   sxt4 r38=3Dr33
					    ^^^^^^^^^^^^^
  1c:   04 00 c4 00                         mov r35=B0;;
  20:   0a 00 00 00 00 02       [MMI]       break.m 0x100000;;
  26:   10 02 20 00 42 e0                   mov r33=3Dr8

"sxt4 r38=3Dr33" is not necessary at all since kernel will never use
the uppper 4 bytes with

asmlinkage long sys_newfstat(unsigned int fd, struct stat * statbuf)

The basically problem is glibc doesn't store information about what
the kernel interface is so that it can't efficiently set up parameters
for system calls. Is there a way to improve the situation?


H.J.
