From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 08:00:28 +0000
Subject: Re: sparse-enablement the 2nd [was Re: yet another sparse-detected bug fix]
Message-Id: <16738.21660.571136.45162@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oh, and here is the diffstat, which I forgot to include in the patch.

	--david

 arch/ia64/Makefile                |    2 
 arch/ia64/hp/common/sba_iommu.c   |   10 -
 arch/ia64/ia32/ia32_ldt.c         |   25 +--
 arch/ia64/ia32/ia32_signal.c      |  131 ++++++++++---------
 arch/ia64/ia32/ia32_support.c     |    4 
 arch/ia64/ia32/ia32priv.h         |    8 -
 arch/ia64/ia32/sys_ia32.c         |  256 +++++++++++++++++++-------------------
 arch/ia64/kernel/acpi-ext.c       |    2 
 arch/ia64/kernel/acpi.c           |    8 -
 arch/ia64/kernel/efi.c            |   10 -
 arch/ia64/kernel/iosapic.c        |   18 +-
 arch/ia64/kernel/irq.c            |    4 
 arch/ia64/kernel/irq_ia64.c       |    7 -
 arch/ia64/kernel/module.c         |   20 +-
 arch/ia64/kernel/palinfo.c        |    2 
 arch/ia64/kernel/patch.c          |   26 +--
 arch/ia64/kernel/perfmon.c        |    6 
 arch/ia64/kernel/process.c        |   22 +--
 arch/ia64/kernel/ptrace.c         |  109 ++++++++++------
 arch/ia64/kernel/salinfo.c        |    6 
 arch/ia64/kernel/setup.c          |    2 
 arch/ia64/kernel/sigframe.h       |    2 
 arch/ia64/kernel/signal.c         |   30 ++--
 arch/ia64/kernel/smp.c            |    2 
 arch/ia64/kernel/sys_ia64.c       |    4 
 arch/ia64/kernel/time.c           |    2 
 arch/ia64/kernel/traps.c          |   25 +--
 arch/ia64/kernel/unaligned.c      |   18 +-
 arch/ia64/kernel/unwind.c         |   30 ++--
 arch/ia64/lib/csum_partial_copy.c |   12 -
 arch/ia64/lib/io.c                |   22 +--
 arch/ia64/mm/contig.c             |    2 
 arch/ia64/mm/extable.c            |    2 
 arch/ia64/mm/fault.c              |    2 
 arch/ia64/mm/init.c               |    8 -
 arch/ia64/mm/tlb.c                |    2 
 drivers/char/agp/hp-agp.c         |   16 +-
 drivers/char/efirtc.c             |   19 +-
 include/asm-ia64/compat.h         |    8 -
 include/asm-ia64/elf.h            |    6 
 include/asm-ia64/gcc_intrin.h     |   24 +--
 include/asm-ia64/hw_irq.h         |    2 
 include/asm-ia64/io.h             |   85 ++++++------
 include/asm-ia64/iosapic.h        |    8 -
 include/asm-ia64/mmu_context.h    |   12 -
 include/asm-ia64/page.h           |    4 
 include/asm-ia64/pgtable.h        |   10 -
 include/asm-ia64/processor.h      |   10 -
 include/asm-ia64/siginfo.h        |    2 
 include/asm-ia64/signal.h         |    4 
 include/asm-ia64/smp.h            |    8 -
 include/asm-ia64/spinlock.h       |    4 
 include/asm-ia64/system.h         |    4 
 include/asm-ia64/uaccess.h        |   87 ++++++++----
 include/asm-ia64/unistd.h         |    4 
 55 files changed, 612 insertions(+), 546 deletions(-)
