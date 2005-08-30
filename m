From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Aug 2005 23:27:41 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200508302327.j7UNRf3L004823@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                          |    6 
 arch/ia64/hp/sim/boot/fw-emu.c             |   11 
 arch/ia64/ia32/ia32_signal.c               |    1 
 arch/ia64/kernel/Makefile                  |    1 
 arch/ia64/kernel/cpufreq/Kconfig           |   29 +
 arch/ia64/kernel/cpufreq/Makefile          |    1 
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c    |  499 ++++++++++++++++++
 arch/ia64/kernel/sys_ia64.c                |    2 
 arch/ia64/lib/Makefile                     |    2 
 arch/ia64/lib/swiotlb.c                    |    5 
 arch/ia64/mm/hugetlbpage.c                 |    8 
 arch/ia64/pci/pci.c                        |    1 
 arch/ia64/sn/include/tio.h                 |    6 
 arch/ia64/sn/include/xtalk/hubdev.h        |   11 
 arch/ia64/sn/kernel/bte.c                  |   85 +--
 arch/ia64/sn/kernel/huberror.c             |    2 
 arch/ia64/sn/kernel/io_init.c              |   35 +
 arch/ia64/sn/kernel/irq.c                  |   75 +-
 arch/ia64/sn/kernel/setup.c                |    7 
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S     |   13 
 arch/ia64/sn/kernel/sn2/sn2_smp.c          |  256 ++++++++-
 arch/ia64/sn/kernel/sn2/sn_hwperf.c        |  319 +++++++++--
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c       |    4 
 arch/ia64/sn/kernel/sn2/timer_interrupt.c  |   22 
 arch/ia64/sn/pci/Makefile                  |    2 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c         |   60 +-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c    |   42 +
 arch/ia64/sn/pci/tioca_provider.c          |    9 
 arch/ia64/sn/pci/tioce_provider.c          |  773 ++++++++++++++++++++++++++++-
 drivers/char/snsc_event.c                  |   11 
 include/asm-ia64/acpi.h                    |    5 
 include/asm-ia64/fcntl.h                   |    3 
 include/asm-ia64/io.h                      |    4 
 include/asm-ia64/mmu.h                     |    8 
 include/asm-ia64/mmu_context.h             |   59 +-
 include/asm-ia64/page.h                    |   31 -
 include/asm-ia64/pal.h                     |   21 
 include/asm-ia64/pgtable.h                 |   13 
 include/asm-ia64/rwsem.h                   |   35 -
 include/asm-ia64/sn/addrs.h                |  114 ++--
 include/asm-ia64/sn/geo.h                  |    3 
 include/asm-ia64/sn/intr.h                 |    3 
 include/asm-ia64/sn/nodepda.h              |    3 
 include/asm-ia64/sn/pcibus_provider_defs.h |    8 
 include/asm-ia64/sn/pda.h                  |    1 
 include/asm-ia64/sn/sn2/sn_hwperf.h        |   10 
 include/asm-ia64/sn/sn_sal.h               |   60 --
 include/asm-ia64/sn/tioce.h                |  740 +++++++++++++++++++++++++++
 include/asm-ia64/sn/tioce_provider.h       |   66 ++
 include/asm-ia64/spinlock.h                |   33 -
 include/asm-ia64/system.h                  |    5 
 51 files changed, 3099 insertions(+), 424 deletions(-)

Adrian Bunk:
  [IA64] arch/ia64/hp/sim/boot/fw-emu.c: remove egcs workaround

Alex Williamson:
  [IA64, X86_64] fix swiotlb sizing

Bjorn Helgaas:
  [IA64] fix IO_SPACE_SPARSE_ENCODING macro ambiguity

Christoph Lameter:
  [IA64] Spinlock optimizations
  [IA64] Remove rwsem limitation of 32k waiters

Colin Ngam:
  [IA64-SGI] Altix only: Add PCI Domain number support.

David Mosberger-Tang:
  [IA64] Fix race in mm-context wrap-around logic.

Greg Edwards:
  [IA64] clean up sn2 region definitions

Greg Howard:
  [IA64-SGI] fix unaligned memory access in snsc_event.c

Jack Steiner:
  [IA64-SGI] - New SN hardware support - addr_macros
  [IA64-SGI] - New SN hardware support - use_alias_space
  [IA64-SGI] - New SN hardware support - boot_init_shub2
  [IA64-SGI] - New SN hardware support - no_wars
  [IA64-SGI] - New SN hardware support - bte_fixes
  [IA64-SGI] - New SN hardware support - cpu_relax
  [IA64-SGI] - New SN hardware support - ptc_fixes

Kenneth Chen:
  [IA64] Delete erroneous copy_page.o in global lib-y list

Kumar Gala:
  [IA64] remove use of asm/segment.h

Mark Goodwin:
  [IA64] - SGI SN hwperf enhancements - export_pci_topology
  [IA64] - SGI SN hwperf enhancements -
  [IA64] - SGI SN hwperf enhancements -

Mark Maule:
  [IA64-SGI] altix: cosmetic rename of SGI_PCIBR_ERROR
  [IA64-SGI] abstract force_interrupt() mechanism
  [IA64-SGI] add support for TIO huge-window
  [IA64-SGI] sn pci provider for TIOCE (pci
  [IA64] altix: Abstract irq_affinity at the sn pci provider

Peter Chubb:
  [IA64] Rationalise Region Definitions

Russ Anderson:
  [IA64] SGI SN remove redundant partition SAL call
  [IA64-SGI] fix bte_copy() calling smp_processor_id() while preemptible

Tony Luck:
  [IA64-SGI] One new use of "UNCACHED" needed fixing for sn2 region cleanup
  [IA64] Low byte of current->personality is not a bitmask.

Venkatesh Pallipadi:
  [IA64] Add ACPI based P-state support

