From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 19:12:21 +0000
Subject: common name for the kernel DSO
Message-Id: <marc-linux-ia64-105596373129064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Both x86 and ia64 now provide a dynamically shared object (DSO) for
system call purposes (e.g., to speed up system calls and for signal
trampoline/sigreturn purposes).  At the moment, the names of these
DSOs are different:

	x86:	linux-vsyscall.so.1
	ia64:	linux-gate.so.1

I think there is some value in using the same name on all platforms
that support such a DSO.  vsyscall makes no sense for ia64, since
there are no virtual syscalls (instead, ia64 linux provides a fast
system call convention which, when coupled with light-weight system
call handlers, provide full syscall semantics at more or less the
speed of virtual system calls).

Not surprisingly, I like the name "linux-gate", since that is really
what this DSO is all about: it's a gateway between user and kernel
space.  However, if this name isn't appropriate for x86, perhaps we
can find another name which will be acceptable to everybody.

I already checked with Roland McGrath (cc'd), and he agrees that a
common name would be good and said that he doesn't care about the
particular name that will be used.

Does anyone have any strong feelings about this?  If not, I plan to
submit a patch to rename the x86 DSO to linux-gate.so.1.

Thanks,

	--david
