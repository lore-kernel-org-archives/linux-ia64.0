From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jan 2003 08:13:08 +0000
Subject: [Linux-ia64] [RFC] proposed change for syscall stub
Message-Id: <marc-linux-ia64-105590709805641@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Given all the work that has gone into glibc to support "lightweight"
kernel-entry on x86 linux, I think the time is ripe to setup things
for ia64 as well.  There are many approaches that we can take to
implement faster system calls in the ia64 kernel but the good news is
that with a few simple changes to glibc, we gain the ability to
support pretty much _any_ approach.  The basic idea is as follows:

The old system call stub looks like this:

old_syscall:
	mov r15 =3D SYSCALL_NR
	break 0x100000;;
	cmp.eq p6,p0 =3D -1, r10
(p6)	br.cond.spnt.few syscall_error
	br.ret.sptk rp

we can replace this by:

new_syscall_stub:
	adds r2 =3D SYSINFO_OFF, r13;;
	ld8 r2 =3D [r2]
	mov r9 =3D ar.pfs;;
	mov b6 =3D r2
	mov r15 =3D SYSCALL_NR;;
	br.call.sptk.many b6=B6;;
	cmp.eq p6,p0 =3D -1, r10
	mov ar.pfs =3D r9
(p6)	br.cond.spnt.few syscall_error
	br.ret.sptk.many rp

Here, SYSINFO_OFF is the offset in the user-level thread-control-block
at which the system call entry point is stored.  glibc initializes
this value to point to the following piece of code:

default_syscall:
	break 0x100000
	br.ret.sptk.many b6

The new setup causes syscall stubs to be somewhat bigger (4 bundles
instead of 2 bundles).  Also, due to the indirection, you'd think that
execution time also is slightly slower, though in practice the
difference is quite small (in fact, for the getpid() test case I used,
the test program reported 349 cycles for the new stub and 351 cycles
for the old one; go figure...).

On the upside, we gain a lot of flexibility: new kernels can override
the syscall entry point in the user-level thread-control-block via the
AT_SYSINFO ELF auxiliary table entry.  For example, this would allow
us to implement light-weight system calls via "epc".  I did a quick &
dirty proof-of-concept and something trivial like getpid, we should be
able to do in well less than 100 cycles (while maintaining full system
call compatibility, including for stuff like signal-delivery checking
and strace'ing).

Now why does the new syscall stub look the way it does?  The goal I
had was to make the new syscall stub a "drop-in" replacement for the
old code sequence.  In particular, I wanted to retain the ability to
do a system call without having to copy around argument registers.  To
make this work, we need to be able to preserve "rp" (b0) and the
contents of ar.pfs without allocating local registers.  For this
reason, the new syscall stub uses a non-standard calling sequence
which requires registers r9 and rp to be preserved.  Other than that,
the stub probably looks like you'd expect.  Fortunately, since the old
kernels preserves these registers anyhow, we should be fine here.

Anyhow, I'd be interested in comments & feedback.  My hope is that we
could make the glibc changes relatively soon, as that would enable
kernel experimentation without affecting user-level in any fashion.

	--david

