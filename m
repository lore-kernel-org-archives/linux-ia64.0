From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:29:13 +0000
Subject: [PATCH 00/15] ia64/pv_ops take 5
Message-Id: <12095585682308-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. This patchset implements ia64/pv_ops support which is the
framework for virtualization support.
Now all the comments so far have been addressed, but only a few exceptions.

On x86 various ways to support virtualization were proposed, and
eventually pv_ops won. So on ia64 the pv_ops strategy is appropriate too.
Later I'll post the patchset which implements xen domU based on
ia64/pv_ops. Currently only ia64/xen pv_ops implementation exists,
but I believe ia64/kvm can also obtain benefits from this ia64/pv_ops
frame work.
linux/ia64 has the machine vector interface and another approach might be
to utilize it. However pv_ops is better for some reasons. Please see
the thread of the mailing list from
http://www.spinics.net/lists/linux-ia64/msg05238.html


This patchset does the followings.
- some preparation work. Mainly make the kernel virtualization friendly.
- introduce pv_info which describes the execution environment.
- introduce macros for hand written assembly code to paravirtualize
  hand written code to replace sensitive/privileged instructions.
- introduce various hooks to replace the implementation with
  paravirtualized.
  They are defined as function tables called, pv_init_ops, pv_cpu_ops,
  pv_irq_ops, pv_iosapic_ops and, pv_time_ops.
  They represent
    pv_init_ops: hooks for various initialization.
    pv_cpu_ops: hooks for ia64 intrinsics.
    pv_irq_ops: hooks for irq related operations.
    pv_iosapic_ops: hooks for paravirtualized iosapic.
    pv_time_ops: hooks for steal time accounting


The working full source is available from
http://people.valinux.co.jp/~yamahata/xen-ia64/linux-2.6-xen-ia64.git/
branch: xen-ia64-2008apr30

At this phase, we don't address the following issues.
Those will be addressed after the first merge.
- optimization by binary patch
  In fact, we had the patch to do that, but we intentionally dropped
  for patch size/readability/cleanness.
- freeing the unused pages, i.e. pages for unused ivt.S.

Changes from take 4:
- refined NR_IRQS paravirtualization according to Jes Soresen's comment
- rebased and fixed the breakage due to the upstream change.
- fixed various compilation errors.

Changes from take 3:
- split the patch set into pv_op part and xen domU part.
- many clean ups.
- introduced pv_ops: pv_cpu_ops and pv_time_ops.

Changes from take 2:
- many clean ups following to comments.
- clean up:assembly instruction macro.
- introduced pv_ops: pv_info, pv_init_ops, pv_iosapic_ops, pv_irq_ops.

Changes from take 1:
Single IVT source code. compile multitimes using assembler macros.

thanks,

Diffstat:
 arch/ia64/Makefile                 |    6 +
 arch/ia64/kernel/Makefile          |   44 +++++
 arch/ia64/kernel/entry.S           |  115 +++++++----
 arch/ia64/kernel/iosapic.c         |   45 +++--
 arch/ia64/kernel/irq_ia64.c        |   19 ++-
 arch/ia64/kernel/ivt.S             |  227 +++++++++++-----------
 arch/ia64/kernel/minstate.h        |   13 +-
 arch/ia64/kernel/nr-irqs.c         |   24 +++
 arch/ia64/kernel/paravirt.c        |  369 ++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/paravirt_inst.h   |   29 +++
 arch/ia64/kernel/paravirtentry.S   |   60 ++++++
 arch/ia64/kernel/setup.c           |   10 +
 arch/ia64/kernel/smpboot.c         |    2 +
 arch/ia64/kernel/time.c            |   23 +++
 include/asm-ia64/Kbuild            |    2 +-
 include/asm-ia64/gcc_intrin.h      |   24 ++--
 include/asm-ia64/hw_irq.h          |   23 ++-
 include/asm-ia64/intel_intrin.h    |   41 ++--
 include/asm-ia64/intrinsics.h      |   55 ++++++
 include/asm-ia64/iosapic.h         |   18 ++-
 include/asm-ia64/irq.h             |    9 +-
 include/asm-ia64/mmu_context.h     |    6 +-
 include/asm-ia64/native/inst.h     |  180 ++++++++++++++++++
 include/asm-ia64/native/irq.h      |   35 ++++
 include/asm-ia64/paravirt.h        |  252 ++++++++++++++++++++++++
 include/asm-ia64/paravirt_privop.h |  114 +++++++++++
 include/asm-ia64/smp.h             |    2 +
 include/asm-ia64/system.h          |   10 +-
 28 files changed, 1520 insertions(+), 237 deletions(-)
