From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:49:09 +0000
Subject: syscall improvement patch [0/12]
Message-Id: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Inspired by the excellent work the UNSW folks did to optimize the L4
IPC hot path, I took another look at the syscall paths (well, I did
cheat a little to get this done in a reasonable amount of time).

The result of this work in in the following series of 12 patches.
They successively improve various aspects of the kernel's syscall
entry and exit paths.  I tried to split them as much as possible into
independent pieces, but since many of them touch the same areas of
code, it's by far easiest to apply them in order.

I have done as much testing as I can and think the patches are all
safe.  For the most part, they're just shuffling instructions around
without any functional/behavior change but then again this is very
low-level code so it's easy to goof.  In particular, I'd very much
like critical minds to review the fsys_bubble_down() changes,
specifically the rationale for why we don't need a srlz.i in that code
(the rationale is both in the patch header and the code comment).

I would be very interested to hear how these patches behave on
syscall-intensive workloads with huge workingsets.

A summary of the effect of the patches on getpid() and getuid()
performance is in the table below (4 of the patches are
cosmetic/cleanup only, so they don't have any performance effects).
In the table below, "EPC" is for EPC-based system calls, "BREAK" for
BREAK-based system-calls (note: the test-programs ensure that getpid()
isn't cached by the C library).  All numbers are cycle counts as
measured on a 1.5GHz/6M Madison.

					  getpid	  getuid
					EPC	BREAK	EPC	BREAK
 Baseline (linux-ia64-test-2.6.12):	40	254	232	249
 Dynamic prediction of RSE-clearing br:	40	252	231	249
 Avoid F-unit stalls after ar.bsp read: 40	246	225	246
 Hint b7 with __kernel_syscall_via_epc:	40	246	219	246
 Use st8 instead of stf8 to clear pt.r8:40	245	217	242
 Read bsp early in ia64_leave_syscall:	40	237	208	232
 Reschedule break_fault:		40	207	208	206
 Reschedule __kernel_syscall_via_epc:	38	207	201	206
 Reschedule fsys_bubble_down:		38	207	180	206

I'd appreciate if you could check these patches into the
linux-ia64-test-2.6.12 repository as soon as possible so we can give
it additional testing-exposure before feeding it into 2.6.13.

Thanks!

	--david
