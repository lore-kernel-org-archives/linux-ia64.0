From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Jan 2005 23:03:03 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200501252303.j0PN33A19074@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.11

This will update the files shown below ... the apparently huge change
to ptrace.c is mostly code reformatting to fit in 80 columns.

Thanks!

-Tony

 arch/ia64/ia32/ia32_signal.c |   20 -
 arch/ia64/ia32/sys_ia32.c    |   33 --
 arch/ia64/kernel/entry.S     |   18 -
 arch/ia64/kernel/perfmon.c   |   17 -
 arch/ia64/kernel/ptrace.c    |  687 +++++++++++++++++++++++++------------------
 arch/ia64/kernel/signal.c    |    9 
 arch/ia64/kernel/sys_ia64.c  |    7 
 arch/ia64/kernel/traps.c     |   76 ++--
 arch/ia64/pci/pci.c          |    2 
 include/asm-ia64/unistd.h    |   14 
 10 files changed, 490 insertions(+), 393 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (05/01/25 1.2031)
   [IA64] entry.S: .align in .text sections is broken, use TEXT_ALIGN()
   
   A few reports of illegal instruction panics while trying to boot
   were tracked to this.  Fix by David Mosberger.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/25 1.2030)
   [IA64] pci_sal_read seg limit is 65535, not 255
   
   Spotted by Andreas Schwab, fix from Matthew Wilcox
   and David Mosberger.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/25 1.2029)
   [IA64] fix ptrace debug-register handling bug
   
   I noticed that the PTRACE_POKEUSR code incorrectly clears bits 56-58
   of _all_ debug registers.  The intention was to only clear it for
   odd-numbered registers, to ensure that user-level can only set
   user-level data/instruction-breakpoints.  Patch below fixes this problem.
   The patch also replaces explicit clearing of the single-step and
   taken-branch PSR bits with a call to ptrace_disable() for PTRACE_KILL.
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/25 1.2028)
   [IA64] clean up pt_regs accesses
   
   This patch replaces the idiom:
   
   	func (args..., long stack) {
   		struct pt_regs *regs = (struct pt_regs *) &stack;
   
   with the more commonly used:
   
   	func (args..., struct pt_regs regs) {
   
   The latter didn't used to work with the very earliest kernels and
   compilers (anybody remember egcs?) but gcc-3.3 and probably even
   gcc-2.96 don't have a problem with it anymore.
   
   The change also makes sparse happier, since it doesn't like it when
   you access memory past the end of the declared size of that variable.
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/25 1.2027)
   [IA64] ptrace.c: Format to make it fit in 80 cols.
   
   David thinks this might make Jesse and Willy happy (or
   at least happier).  If they can cope with line breaks
   before a binary operator, rather than after, then maybe
   it will :-)
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kenneth.w.chen@intel.com> (05/01/25 1.2026)
   [IA64] Ensure that r9 can't be a NaT on return from sys_pipe()
   
   This version doesn't cost us any extra cycles.
   
   Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
   Signed-off-by: Rohit Seth <rohit.seth@intel.com>
   Acked-by: David Mosberger <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

