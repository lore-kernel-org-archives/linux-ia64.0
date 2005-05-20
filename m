From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 May 2005 16:17:06 +0000
Subject: libunwind patch for v2.6 kernel
Message-Id: <200505201617.j4KGH6Vd023372@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm happy to announce that a first version of a libunwind-based ia64
linux kernel is now available.  A patch relative to the current (May
20th) GIT tree by Tony is now available at:

 ftp://ftp.hpl.hp.com/pub/linux-ia64/unwind-2.6-050520.diff.gz

The patch is ~80KB in size --- big enough that I didn't want to spam
everybody's mailbox.

From a user-perspective, this patch should make zero difference.  From
a kernel-perspective, it provides the following advantages:

 - Same API as for user-level libunwind.
	o Makes for easier learning.
	o Gets rid of difficult-to-use unw_init_running() in favor
	  of a much simpler unw_getcontext()/unw_local_init()
	  (take a look at process.c to see how much this simplifies
	   things).
	o The state-model is MUCH simpler: the register state simply
	  corresponds to the instruction at which IP points; no need
	  to make confusing distinctions between frame registers,
	  preserved registers, etc.

 - 99% of the code is shared with user-level libunwind.
	o Makes for much easier code-maintainenance.
	o Kernel unwinder benefits from the stringent testing
	  done at the user-level.

 - Libunwind is architecture-independent so it could potentially be
   enabled on other architectures, such as PA-RISC, Alpha, and
   x86/x86-64.

 - Libunwind supports multiple register backing-stores, which should
   make it possible to clean up the MCA code significantly, as we
   discussed earlier.

I should warn that this is still a work-in-progress and not meant for
inclusion in the official tree just yet.  Having said that, I tested
INIT dumps, core-dumps, wait-channels, and ran the gdb test-suite with
no regressions.  On the other hand, I know that stracing an x86
program doing a fork currently hangs, so there is at least one bug
still lurking out there.  Also, I expect some more code-factoring to
happen, especially if support for other architectures were to be added
(PA-RISC and Alpha are probably the most obvious candidates).  I
haven't done any performance-measurements yet.  Eventually, I expect
libunwind to perform about the same as the current kernel-unwinder but
at the moment a lot of debug-code is enabled.

If you take a look or give it a whirl, please let me know what you
think.

Thanks,

	--david
