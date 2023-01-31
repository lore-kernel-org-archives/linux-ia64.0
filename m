From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 31 Jan 2023 20:02:51 +0000
Subject: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y9lz6yk113LmC9SI@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

	Page fault handlers generally react to VM_FAULT_RETRY from
handle_mm_fault() by repeating the whole thing (starting with locking
mmap) with FAULT_FLAG_TRIED added to flags.

	However, there are two cases when that's not the right thing
to do:

1) fault has happened in userland and we have a pending signal.  In that
case we'd better return from fault handler immediately.

2) fault has happened in kernel (e.g. in something like copy_from_user())
and we have a pending *fatal* signal.  Solution is to handle that as if
handle_mm_fault() had failed; we have come from kernel mode, so we'd
better have an exception table entry for the fauling insn.  Find it
and deal with it; from the copy_from_user() (or whatever it was that
triggered our fault) caller's POV it's indistinguishable from running
into an unmapped area, so it will fail.  The process is not going to
survive anyway.

Quietly returning from #PF handler in the second case is asking for
livelock - one common case when handle_mm_fault() returns VM_FAULT_RETRY
is when it needs to wait for page lock and gets hit by a fatal signal.
Running into that in any uaccess primitive will end up repeating the
faulting insn again and again, as long as we hit that case in
handle_mm_fault().  Eventually it might get out (e.g. trylock
manages to get page lock without hitting the "wait for it" codepath),
but it's obviously not a good situation.

On x86 it had been noticed and fixed back in 2014, in 26178ec11ef3 "x86:
mm: consolidate VM_FAULT_RETRY handling".  Some of the other architectures
had it dealt with later - e.g. arm in 2017, the fix is 746a272e44141
"ARM: 8692/1: mm: abort uaccess retries upon fatal signal"; xtensa -
in 2021, the fix is 7b9acbb6aad4f "xtensa: fix uaccess-related livelock
in do_page_fault", etc.

However, it never had been done on a bunch of architectures - the
current mainline still has that bug on alpha, hexagon, itanic, m68k,
microblaze, nios2, openrisc, parisc, riscv and sparc (both sparc32 and
sparc64).  Fixes are trivial, but I've no way to test them for most
of those architectures.
