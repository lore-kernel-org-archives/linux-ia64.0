From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 18 Mar 2005 21:03:15 +0000
Subject: bk pull on 2.4 ia64 linux tree
Message-Id: <1111179795.13286.64.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the following files:

 arch/ia64/configs/dig           |   20 ++++++++++++-----
 arch/ia64/configs/generic       |   20 ++++++++++++-----
 arch/ia64/configs/numa          |   20 ++++++++++++-----
 arch/ia64/configs/ski           |   17 ++++++++++----
 arch/ia64/configs/zx1           |   20 ++++++++++++-----
 arch/ia64/defconfig             |   20 ++++++++++++-----
 arch/ia64/hp/common/sba_iommu.c |    9 +++++++
 arch/ia64/kernel/entry.S        |   27 +++++++++++++++++-----
 arch/ia64/kernel/ivt.S          |   47 +++++++++++++++++++++-------------------
 arch/ia64/kernel/palinfo.c      |    2 -
 arch/ia64/kernel/process.c      |    2 -
 arch/ia64/kernel/unwind.c       |   38 +++++++++++++++++++-------------
 arch/ia64/vmlinux.lds.S         |    7 +++++
 include/asm-ia64/pgtable.h      |    9 ++++---
 14 files changed, 178 insertions(+), 80 deletions(-)

through these ChangeSets:

<kaos@sgi.com> (05/03/18 1.1466)
   [IA64] Tighten up unw_unwind_to_user check
   
   Detect user space by the unwind frame with predicate PRED_USER_STACK
   set, instead of a user space IP.  Tighten up the last ditch check for
   running off the top of the kernel stack.
   
   Based on a suggestion by David Mosberger, reworked to fit the current
   tree.  This survives my stress test which used to break 2.6.9 kernels.
   Unlike 2.6.11, the stress test now unwinds to the correct point, so
   gdb can get the user space registers.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjorn.helgaas@hp.com> (05/03/12 1.1464)
   ia64: Update defconfigs.

<yanmin.zhang@intel.com> (05/03/12 1.1463)
   [IA64] clean up ptrace corner cases
   
   Patch from yanmin.zhang@intel.com to fix up some corner cases
   in ptrace.  Many thanks to davidm for reviewing and improving.
   
   Backported to 2.4 by Bjorn Helgaas (bjorn.helgaas@hp.com).

<kaos@sgi.com> (05/03/12 1.1462)
   [IA64] Sanity check unw_unwind_to_user
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjorn.helgaas@hp.com> (05/03/12 1.1461)
   ia64: add missing syscall-slot.

<bjorn.helgaas@hp.com> (04/08/31 1.1459)
   ia64: fix perfmon typo in /proc/pal/CPU*/processor_info w.r.t. BERR
   
   Initially reported by Danny Kwong from HP.
   
   Signed-Off-By: stephane eranian <eranian@hpl.hp.com>
   Signed-Off-By: Bjorn Helgaas <bjorn.helgaas@hp.com>

<davidm@tiger.hpl.hp.com> (04/08/03 1.1455)
   ia64: Fix _PAGE_CHG_MASK so PROT_NONE works again.  Caught by Linus.

<davidm@tiger.hpl.hp.com> (04/08/03 1.1454)
   Fix pte_modify() bug which allowed mprotect() to change too many bits.
   Found by Russell King.

<bjorn.helgaas@hp.com> (04/07/02 1.1451)
   ia64: round iommu allocations to power-of-two sizes.
   
   Round IOVA allocations to power-of-two sizes to avoid
   REO/Grande defect AR2305.

<bjorn.helgaas@hp.com> (04/07/02 1.1450)
   [PATCH] ia64: force all kernel sections into one and the same segment
   
   Older versions of the linker do not handle cross-segment segment-relative
   relocations properly.  This becomes a real problem when the linker decides
   to put .text and .text.init into different segments (for whatever reasons)
   because in that case, broken linkers will produce a broken unwind section,
   which can cause nasty Heisenbugs, where, for example, unwinding may or may
   not work depending on the exact value of the IP in a function.
   
   [Backport of Keith Owens' 2.6 change]


Thanks!

Bjorn


