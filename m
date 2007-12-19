From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Dec 2007 22:01:36 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC26D981@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/common/sba_iommu.c   |    3 ++-
 arch/ia64/ia32/binfmt_elf32.c     |   28 ++++++++++++----------------
 arch/ia64/kernel/head.S           |    1 +
 arch/ia64/kernel/irq_ia64.c       |    4 ++--
 arch/ia64/kernel/mca.c            |   33 +++++++++++++++++++++++++++++++++
 arch/ia64/kernel/process.c        |    7 +++++--
 arch/ia64/kernel/signal.c         |   10 +---------
 arch/ia64/kernel/uncached.c       |    2 +-
 arch/ia64/mm/tlb.c                |   18 +++++++++++++++---
 arch/ia64/sn/kernel/bte.c         |    4 ++--
 arch/ia64/sn/kernel/bte_error.c   |    8 ++++++--
 arch/ia64/sn/pci/tioce_provider.c |    2 +-
 include/asm-ia64/bitops.h         |   17 ++++++++++++++---
 include/asm-ia64/gcc_intrin.h     |    5 +++++
 include/asm-ia64/hw_irq.h         |    2 +-
 include/asm-ia64/intel_intrin.h   |    3 +++
 include/asm-ia64/sn/bte.h         |   31 ++++++++++++++++++++++++++++++-
 include/asm-ia64/sn/xp.h          |   27 +++++++++++++++++++++++++--
 include/asm-ia64/sn/xpc.h         |    8 +++++++-
 include/asm-ia64/tlbflush.h       |    6 +++++-
 20 files changed, 171 insertions(+), 48 deletions(-)

Christoph Lameter (1):
      IA64: Slim down __clear_bit_unlock

Hidetoshi Seto (2):
      [IA64] Remove assembler warnings on head.S
      [IA64] Adjust CMCI mask on CPU hotplug

Ian Wienand (1):
      [IA64] set_thread_area fails in IA32 chroot

Jan Beulich (1):
      [IA64] make flush_tlb_kernel_range() an inline function

Joe Perches (1):
      [IA64] Two trivial spelling fixes

Kenji Kaneshige (1):
      [IA64] Remove compiler warinings about uninitialized variable in irq_ia64.c

Nick Piggin (1):
      [IA64] ia32 nopage

Russ Anderson (1):
      [IA64] Fix Altix BTE error return status

Shi Weihua (1):
      [IA64] signal: remove redundant code in setup_sigcontext()

Simon Horman (1):
      [IA64] Guard elfcorehdr_addr with #if CONFIG_PROC_FS

Tony Luck (1):
      [IA64] print kernel release in OOPS to make kerneloops.org happy

de Dinechin, Christophe (Integrity VM) (1):
      [IA64] Avoid unnecessary TLB flushes when allocating memory



