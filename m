From: Mike Frysinger <vapier@gentoo.org>
Date: Sun, 06 May 2012 20:45:23 +0000
Subject: getcpu() returns EFAULT when called via the vdso
Message-Id: <201205061645.24398.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart4355711.nq73UHuyJq"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--nextPart4355711.nq73UHuyJq
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

sched_getcpu() on my ia64 systems is failing with EFAULT.  simple test code:

$ cat test.c
#define _GNU_SOURCE
#include <errno.h>
#include <sched.h>
#include <stdio.h>
#include <string.h>
#include <sys/syscall.h>
main() {
	int i, e;
	puts("");
close(444);
	kill(0, 0);
close(333);
	syscall(__NR_getcpu, &i, 0, 0);
close(123);
	errno =3D 0;
	i =3D sched_getcpu();
	e =3D errno;
close(321);
	printf("getcpu() =3D %i: %s\n", i, strerror(e));
}
the puts() is to force initialization of some internal libc stuff so the st=
race=20
output is easier to read later on.  the close() calls make it easy to pick =
out=20
the different steps.

when i run this with newer glibc versions (like 2.13+), i get:
	getcpu() =3D -1: Bad address

running it through strace, we see:
close(444)                              =3D -1 EBADF (Bad file descriptor)
kill(0, SIG_0)                          =3D 0
close(333)                              =3D -1 EBADF (Bad file descriptor)
getcpu([1], NULL, 0)                    =3D 0
close(123)                              =3D -1 EBADF (Bad file descriptor)
close(321)                              =3D -1 EBADF (Bad file descriptor)
write(1, "\ngetcpu() =3D -1: Bad address\n", 28) =3D 28

you can see the syscall() working, but the sched_getcpu() doesn't seem to m=
ake=20
it into supervisor mode.  glibc internally uses the vdso for doing most=20
syscalls (while the syscall() func sticks to the old break method).  since =
we=20
know kill() and sched_getcpu() use the vdso, we know strace can handle both=
=20
styles fine since kill() gets decoded.  so that leaves something funky.

the sched_getcpu() code is somewhat simple:
int sched_getcpu (void) {
	unsigned int cpu;
	int r =3D INLINE_SYSCALL (getcpu, 3, &cpu, NULL, NULL);
	return r =3D=3D -1 ? r : cpu;
}
so it passes in a pointer to an int on the stack, and 2 null pointers ...

the disassembly of the sched_getcpu() code at runtime looks like:
   0x2000000000203940 <+0>:     [MMI]       alloc r32=3Dar.pfs,9,1,0
   0x2000000000203941 <+1>:                 adds r14=3D8,r13
   0x2000000000203942 <+2>:                 mov r33=3Dr12;;
   0x2000000000203950 <+16>:    [MMI]       ld8 r14=3D[r14]
   0x2000000000203951 <+17>:                nop.m 0x0
   0x2000000000203952 <+18>:                mov r15=3D1304
   0x2000000000203960 <+32>:    [MII]       mov r35=3Dr0
   0x2000000000203961 <+33>:                mov r34=3Dr0;;
   0x2000000000203962 <+34>:                mov b7=3Dr14;;
   0x2000000000203970 <+48>:    [MIB]       nop.m 0x0
   0x2000000000203971 <+49>:                nop.i 0x0
   0x2000000000203972 <+50>:                br.call.sptk.many b6=3Db7;;

so we see:
 - b7 gets loaded with a pointer to the __kernel_syscall_via_epc entry point
 - r15 gets the right syscall number (1304 for __NR_getcpu)
 - r33 is a pointer to the stack (gdb shows it is in the $sp region)
 - r34 and r35 get zeroed out

yet once i step over the call to __kernel_syscall_via_epc, i see r8 is set =
to=20
14 (EFAULT).  i can't see that value being setup in kernel/gate.S, but my=20
knowledge of ia64 assembly isn't that great, nor the kernel paths, so i'm=20
hoping someone can point out the obvious to me here.

i've tested linux 3.0.6 and 3.1.6, glibc 2.13 and 2.15/2.16, and gcc 4.5.3=
=20
(just what i have access to).  they all behave the same.
=2Dmike

--nextPart4355711.nq73UHuyJq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPpuLkAAoJEEFjO5/oN/WB/mwQAIitPsxZFt6O7OCB/9nlUWHV
rf4QDflRozDZn2MWsXkl7G6PDm4EmwkJUXGNLtgl8PB6wns8p/+ZTuQt07X4S9qy
q+cMqjfq7cUJPQRkgiB4E0BaqqRbHw0FlEgiVZSRFYPFnTFjvEx4VdkEPyBZ/YCh
21xEHpmQ5ooPMkUzw8ryGl4c+VHEGRREDId3iqJhnvAiN+IwWP0MaE2zqtaBhd04
H92xfKY+JK4XfLDfXKOltFWms2DWVcssuTAebAOg9vPql/q4pPPg+y2sSqAiuMwB
M7/+QuPW0KWQCMEnXGzQPJ+V/jdfT5pmz6SEJ6RH5Zxz/XRFGqraMJB5Qhg7LfhV
NACjnUBq4itvnVneFqE3K02QpBJxCympCd+G/+BPZZQntV8BhDMbBrjk/JjBlk69
Id1EGs+L5Jj2ppIY9gRyRIOI2nq7Ks8Mpkqf9N7abcgGOemKxv/My9uiljKH2tKn
0Z7XcW+pWG8F9X0FFJ7kZtDvcVrwbDkYwdqR6Z/M6PD48rqNi2gdpGs3OxSPVJt3
inch0bJQwPCFytwjIxqZXIk0UGU0AMZOxpxAZb138iT7l1ScGo/+T8OqyKqIYixG
4wvjbR1+9/Hd8hM3fiG1/y3c+SRN7Gevchmkln9I5cMr7Fxvgi0aWu3s3sQHTKFI
kJ9Y9GFSwB0x8rNXrb1A
=ofBL
-----END PGP SIGNATURE-----

--nextPart4355711.nq73UHuyJq--
