From: Jacky Malcles <Jacky.Malcles@bull.net>
Date: Thu, 02 May 2002 14:55:19 +0000
Subject: [Linux-ia64] readdir(3) return and error code
Message-Id: <marc-linux-ia64-105590701905544@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While doing some testing I came across something that is odd for me,
according to readdir(3) EBADF is returned for an invalid argument.

I'm doing a basic call with a bad argument i,e:
    struct dirent *dptr;
    dptr = readdir("test_dir_1");

I thought that the call would return
  errno = 9 : Bad file descriptor and dptr=NULL

 but,

 on an ia32 platform (Linux version 2.4.9-31custom)
I get:

Program received signal SIGSEGV, Segmentation fault.
__readdir (dirp=0x804be44) at ../sysdeps/unix/readdir.c:82
82      ../sysdeps/unix/readdir.c: No such file or directory.
        in ../sysdeps/unix/readdir.c
(gdb) where
#0  __readdir (dirp=0x804be44) at ../sysdeps/unix/readdir.c:82
#1  0x08049113 in main ()
#2  0x40045507 in __libc_start_main (main=0x8049020 <main>, argc=1,
    ubp_av=0xbfffe524, init=0x8048b7c <_init>, fini=0x804bde0 <_fini>,
    rtld_fini=0x4000dc14 <_dl_fini>, stack_end=0xbfffe51c)
    at ../sysdeps/generic/libc-start.c:129
(gdb)

if I do this to an ia64 platform (Linux version 2.4.17)
I get
errno = 9 : Bad file descriptor and dptr=NULL,


so, is there anything wrong with the libc ? 
can or cannot I write a test code like that ?
is it a pb of shell, version ...

thanks for your help,

Email : Jacky.Malcles@bull.net

