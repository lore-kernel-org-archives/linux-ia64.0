From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Dec 2003 02:00:27 +0000
Subject: new syscall-stub support now in CVS glibc
Message-Id: <marc-linux-ia64-107110849625591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest CVS tree of glibc now sports official support for the new
syscall-stubs (which enable EPC-based kernel entry and light-weight
system call handlers).  For backwards-compatibility reasons, the new
stubs will only be used for NPTL/TLS-enabled versions of libc, but
that should be the normal case for most distros already (or it will be
the normal case soon).

Compared to the stubs which we discussed earlier on this list, there
was one small change: the kernel entry point is now being stored at
offset 8 instead of -8 of the thread-pointer (register r13).  It turns
out that was easier to support in NPTL and since that word is
thread-library-specific anyhow, there was no reason not to use it.  In
other words, the latest new syscall-stubs look like this:

	adds r2 = 8, r13;;
	ld8 r2 = [r2]
	.save ar.pfs, r11
	mov r11 = ar.pfs;;
	.body
	mov r15 = SYSCALLNUMBER
	mov b7 = r2
	br.call.sptk.many b6 = b7
	.restore sp
	mov ar.pfs = r11

Of course, no application should rely on this (they should use
syscall() instead, if necessary), but I just mention it for
completeness.

If you want to play with the new syscall-stubs, you'll need to update
GCC first because the existing GCCs have unwinders that aren't
sufficiently capable of supporting the new syscall-stubs.  Jakub
Jelinek submitted a patch [1] for this already.  The alternative (and
recommended) way to get GCC updated is to install libunwind v0.96 [2]
first and then to build GCC v3.3.x or newer.  GCC will automatically
detect the presence of libunwind and use it as the unwinder in that
case.

Enjoy,

	--david

[1] http://gcc.gnu.org/ml/gcc-patches/2003-12/msg00940.html
[2] http://www.hpl.hp.com/research/linux/libunwind/
