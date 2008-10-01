From: Roland McGrath <roland@redhat.com>
Date: Wed, 01 Oct 2008 22:06:09 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <20081001220609.EB8B31544B4@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There is one warning from the compiler:
> 
> arch/ia64/kernel/ptrace.c:1243: warning: ignoring return value of 'tracehook_report_syscall_entry', declared with attribute warn_unused_result

This means the arch work is incomplete.  From wiki howto item #8:
     
      Note that the calling arch code should handle the return value from
      tracehook_report_syscall_entry(), which is behavior that was not
      required for the old ptrace support. This needs to implement some
      form of safe abort of the syscall. See the kerneldoc comments for the
      exact details.

From linux/tracehook.h kerneldoc comments:

 * Returns zero normally, or nonzero if the calling arch code should abort
 * the system call.  That must prevent normal entry so no system call is
 * made.  If @task ever returns to user mode after this, its register state
 * is unspecified, but should be something harmless like an %ENOSYS error
 * return.  It should preserve enough information so that syscall_rollback()
 * can work (see asm-generic/syscall.h).

> How do I tell whether it is all working?  Roland's wiki
> that you pointed to in patch 0/4 doesn't have any testing
> tips (and seems to have some old information ... it talks
> about CONFIG_UTRACE being available after HAVE_ARCH_TRACEHOOK
> is enabled ... but grep says there are no UTRACE references in
> the kernel).

The information is not old.  It is explaining that this is a prerequisite
to enable the utrace patch series.  You don't have to have that series to
meet the CONFIG_HAVE_ARCH_TRACEHOOK mandates.

In 2.6.27 the only new thing there is to test is /proc/pid/syscall.  The
other testing you can do is verify that there are no regressions for using
strace, gdb, etc.  The ptrace-tests suite (look around the same wiki) is a
good place to start, and the gdb test suite.  (Just worry about regressions
from 2.6.27-rc8 or earlier vanilla kernels, not the absolute failure rate.)


Thanks,
Roland
