From: Bdale Garbee <bdale@gag.com>
Date: Mon, 11 Jun 2001 22:56:55 +0000
Subject: [Linux-ia64] problem with mmap?
Message-Id: <marc-linux-ia64-105590693005712@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In chasing down a problem in the Debian installation toolset where sed was
generating no output when processing /proc/mounts, we discovered what looks
like a bug.

The kernel is allowing an mmap of /proc/mounts to succeed, which gives sed 
a 0-byte mmap'ed file.  On other architectures, the mmap fails so sed resorts
to normal reading which works fine.

An strace of a trivial test case that works elsewhere but not on IA-64 using 
sed is attached.  The SYS_1212 is actually an fstat.

This is 2.4.5 with the 010530 patch set applied, running on a single B3.

Bdale


execve("./sed", ["./sed", "-e", "", "/proc/mounts"], [/* 17 vars */]) = 0
uname({sys="Linux", node="itanium", ...}) = 0
brk(0)                                  = 0x600000000000ceb8
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
SYS_1212(0x3, 0x80000fffffffaee0, 0, 0, 0, 0, 0, 0) = 0
mmap(NULL, 24060, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2000000000030000
close(3)                                = 0
open("/lib/libc.so.6.1", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0002\0\1\0\0\0\260\225"..., 1024) = 1024
SYS_1212(0x3, 0x80000fffffffaee0, 0, 0, 0, 0, 0, 0) = 0
mmap(NULL, 2457296, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x2000000000044000
mprotect(0x200000000027c000, 130768, PROT_NONE) = 0
mmap(0x2000000000284000, 81920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x230000) = 0x2000000000284000
mmap(0x2000000000298000, 16080, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2000000000298000
close(3)                                = 0
mmap(NULL, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2000000000038000
munmap(0x2000000000030000, 24060)       = 0
getpid()                                = 31236
brk(0)                                  = 0x600000000000ceb8
brk(0x600000000000cf18)                 = 0x600000000000cf18
brk(0x6000000000010000)                 = 0x6000000000010000
open("/proc/mounts", O_RDONLY)          = 3
SYS_1212(0x3, 0x80000fffffffbbe0, 0x80000fffffffbe72, 0, 0x1b6, 0, 0x600000000000c690, 0x200000000003d6e0) = 0
mmap(NULL, 0, PROT_READ, MAP_PRIVATE, 3, 0) = 0
close(3)                                = 0
close(1)                                = 0
exit(0)                                 = ?

