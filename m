From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 12 Nov 2004 17:42:43 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200411121742.iACHghM32236@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.10

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/entry.S  |    4 ++--
 arch/ia64/kernel/ivt.S    |   31 ++++++++++++++++---------------
 arch/ia64/kernel/mca.c    |    1 +
 arch/ia64/kernel/ptrace.c |   31 +++++++++----------------------
 arch/ia64/kernel/signal.c |    8 +++-----
 arch/ia64/kernel/smp.c    |    8 ++++----
 include/asm-ia64/ptrace.h |    8 ++++++--
 include/asm-ia64/unistd.h |    3 ++-
 8 files changed, 43 insertions(+), 51 deletions(-)

through these ChangeSets:

<fenghua.yu@intel.com> (04/11/11 1.2091)
   [IA64] add cpu_relax() in the body of spin loops
   
   This patch adds cpu_relax() in the body of spin loops in
   smp_call_function(), smp_call_function_single(), and
   ia64_mca_wakeup_ipi_wait().
   
   Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/11/10 1.2090)
   [IA64] speedup ptrace by avoiding kernel-stack walk
   
   This patch changes the syscall entry path to store the
   current-frame-mask (CFM) in pt_regs->cr_ifs.  This just takes one
   extra instruction (a "dep" to clear the bits other than 0-37) and is
   free in terms of cycles.
   
   The advantage of doing this is that it lets ptrace() avoid having to
   walk the stack to determine the end of the user-level backing-store of
   a process which is in the middle of a system-call.  Since this is what
   strace does all the time, this speeds up strace quite a bit (by ~50%).
   More importantly, it makes the syscall vs. non-syscall case much more
   symmetric, which is always something I wanted.
   
   Note that the change to ivt.S looks big but this is just a rippling
   effect of instruction-scheduling to keep syscall latency the same.
   All that's really going on there is that instead of storing 0 into
   cr_ifs member we store the low 38 bits of ar.pfs.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/11/05 1.2026.59.1)
   [IA64] Allocate syscall #1270 for waitid syscall.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

