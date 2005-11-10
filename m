From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Nov 2005 23:27:16 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200511102327.jAANRGvv028072@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/efi.c              |    2 
 arch/ia64/kernel/kprobes.c          |   22 +++---
 arch/ia64/kernel/mca.c              |  120 ++++++++++++++++++++++++++++--------
 arch/ia64/kernel/mca_drv.c          |   17 +++--
 arch/ia64/kernel/process.c          |    6 +
 arch/ia64/kernel/setup.c            |    1 
 arch/ia64/kernel/signal.c           |   11 +--
 arch/ia64/kernel/traps.c            |   44 ++++++-------
 arch/ia64/mm/discontig.c            |   19 ++---
 arch/ia64/mm/tlb.c                  |   91 +++++++++++++--------------
 arch/ia64/pci/pci.c                 |  106 ++++++++++++++++++++++++-------
 arch/ia64/sn/kernel/io_init.c       |    2 
 arch/ia64/sn/kernel/xpc.h           |    2 
 arch/ia64/sn/kernel/xpc_main.c      |  102 ++++++++++++++++++++++++++++++
 arch/ia64/sn/kernel/xpc_partition.c |    8 +-
 arch/ia64/sn/pci/tioce_provider.c   |    6 -
 include/asm-ia64/kdebug.h           |   30 ++++++++-
 include/asm-ia64/mmu_context.h      |   99 ++++++++++++++++-------------
 include/asm-ia64/tlbflush.h         |    1 
 19 files changed, 487 insertions(+), 202 deletions(-)

Bjorn Helgaas:
      [IA64] add the MMIO regions that are translated to I/O port space to /proc/iomem

Bob Picco:
      [IA64] fix memory less node allocation

Chen, Kenneth W:
      [IA64] make mmu_context.h and tlb.c 80-column friendly

David Mosberger-Tang:
      [IA64] align signal-frame even when not using alternate signal-stack

Dean Nelson:
      [IA64] utilize notify_die() for XPC disengage

Keith Owens:
      [IA64] Extend notify_die() hooks for IA64

Panagiotis Issaris:
      [IA64] Replace kcalloc(1, with kzalloc.

Peter Keilty:
      [IA64] Use bitmaps for efficient context allocation/free

Russ Anderson:
      [IA64] MCA recovery based on PSP bits

