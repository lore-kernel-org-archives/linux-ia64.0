From: Andreas Schwab <schwab@suse.de>
Date: Thu, 26 Sep 2002 19:19:31 +0000
Subject: [Linux-ia64] Syscall tracing bug
Message-Id: <marc-linux-ia64-105590701906071@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

There is some problem with tracing syscall(2) in strace.  It sees the
actual syscall, but the arguments are shifted, with the first arg being
the syscall number.  For example:

$ cat syscall.c
#include <unistd.h>
#include <sys/syscall.h>

int
main ()
{
  write (1, "Hello World\n", 12);
  syscall (SYS_write, 1, "Hello World\n", 12);
  return 0;
}
$ stace ./syscall
execve("./syscall", ["./syscall"], [/* 91 vars */]) =3D 0
uname({sys=3D"Linux", node=3D"sykes", ...}) =3D 0
brk(0)                                  =3D 0x6000000000000b30
open("/etc/ld.so.preload", O_RDONLY)    =3D -1 ENOENT (No such file or dire=
ctory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=84982, ...}) =3D 0
mmap(NULL, 84982, PROT_READ, MAP_PRIVATE, 5, 0) =3D 0x2000000000040000
close(5)                                =3D 0
open("/lib/libc.so.6.1", O_RDONLY)      =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0002\0\1\0\0\0\240@\3"..., 1024)=
 =3D 1024
fstat(5, {st_mode=3DS_IFREG|0755, st_size#50193, ...}) =3D 0
mmap(NULL, 2260816, PROT_READ|PROT_EXEC, MAP_PRIVATE, 5, 0) =3D 0x200000000=
0058000
mprotect(0x2000000000260000, 130896, PROT_NONE) =3D 0
mmap(0x2000000000268000, 81920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED=
, 5, 0x200000) =3D 0x2000000000268000
mmap(0x200000000027c000, 16208, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED=
|MAP_ANONYMOUS, -1, 0) =3D 0x200000000027c000
close(5)                                =3D 0
mmap(NULL, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D 0x2000000000028000
munmap(0x2000000000040000, 84982)       =3D 0
write(1, "Hello World\n", 12Hello World
)           =3D 12
write(1027, ptrace: umoven: Input/output error
0x1, 4611686018427389952Hello World
)   =3D 12
exit(0)                                 =3D ?

Is this a bug in strace or in the kernel (maybe <asm/rse.h>)?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

