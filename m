From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 28 Oct 2005 23:52:20 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200510282352.j9SNqK7u005731@agluck-lia64.sc.intel.com>
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

 arch/ia64/Kconfig                        |   98 +-
 arch/ia64/configs/bigsur_defconfig       |  395 ++++++---
 arch/ia64/configs/gensparse_defconfig    | 1319 +++++++++++++++++++++++++++++++
 arch/ia64/configs/tiger_defconfig        |   86 +-
 arch/ia64/configs/zx1_defconfig          |   92 +-
 arch/ia64/defconfig                      |  265 ++++--
 arch/ia64/hp/common/hwsw_iommu.c         |   13 
 arch/ia64/hp/common/sba_iommu.c          |   45 -
 arch/ia64/hp/sim/simscsi.c               |   13 
 arch/ia64/kernel/acpi.c                  |   13 
 arch/ia64/kernel/efi.c                   |  510 +++++++----
 arch/ia64/kernel/irq.c                   |   12 
 arch/ia64/kernel/mca.c                   |    4 
 arch/ia64/kernel/module.c                |    6 
 arch/ia64/kernel/patch.c                 |   16 
 arch/ia64/kernel/ptrace.c                |   28 
 arch/ia64/kernel/setup.c                 |   67 +
 arch/ia64/kernel/smp.c                   |   10 
 arch/ia64/kernel/smpboot.c               |    6 
 arch/ia64/kernel/uncached.c              |   17 
 arch/ia64/lib/swiotlb.c                  |  102 ++
 arch/ia64/mm/Makefile                    |    5 
 arch/ia64/mm/contig.c                    |    4 
 arch/ia64/mm/discontig.c                 |   43 -
 arch/ia64/mm/init.c                      |    2 
 arch/ia64/mm/numa.c                      |   24 
 arch/ia64/mm/tlb.c                       |   21 
 arch/ia64/pci/pci.c                      |   58 -
 arch/ia64/sn/kernel/bte.c                |    2 
 arch/ia64/sn/kernel/io_init.c            |    4 
 arch/ia64/sn/kernel/setup.c              |  162 +--
 arch/ia64/sn/kernel/sn2/sn2_smp.c        |   31 
 arch/ia64/sn/kernel/sn2/sn_hwperf.c      |    4 
 arch/ia64/sn/kernel/tiocx.c              |   63 -
 arch/ia64/sn/kernel/xpc.h                |  386 +++++++--
 arch/ia64/sn/kernel/xpc_channel.c        |  333 ++++---
 arch/ia64/sn/kernel/xpc_main.c           |  398 ++++++---
 arch/ia64/sn/kernel/xpc_partition.c      |  501 ++++++++---
 arch/ia64/sn/pci/pci_dma.c               |   46 +
 arch/ia64/sn/pci/pcibr/pcibr_reg.c       |   59 -
 arch/ia64/sn/pci/tioca_provider.c        |   32 
 arch/ia64/sn/pci/tioce_provider.c        |   30 
 drivers/char/agp/sgi-agp.c               |    1 
 drivers/char/mmtimer.c                   |    4 
 drivers/char/snsc.c                      |    4 
 include/asm-ia64/machvec.h               |    2 
 include/asm-ia64/machvec_hpzx1.h         |   21 
 include/asm-ia64/machvec_hpzx1_swiotlb.h |    3 
 include/asm-ia64/meminit.h               |    6 
 include/asm-ia64/mmzone.h                |   10 
 include/asm-ia64/nodedata.h              |    4 
 include/asm-ia64/page.h                  |    6 
 include/asm-ia64/sn/arch.h               |   38 
 include/asm-ia64/sn/io.h                 |   11 
 include/asm-ia64/sn/klconfig.h           |   34 
 include/asm-ia64/sn/l1.h                 |   12 
 include/asm-ia64/sn/nodepda.h            |    1 
 include/asm-ia64/sn/sn_cpuid.h           |    3 
 include/asm-ia64/sn/sn_sal.h             |   59 +
 include/asm-ia64/sn/tioca_provider.h     |   14 
 include/asm-ia64/sn/tiocx.h              |    3 
 include/asm-ia64/sn/xp.h                 |   18 
 include/asm-ia64/sparsemem.h             |   20 
 63 files changed, 4234 insertions(+), 1365 deletions(-)

Alex Williamson:
      [IA64] more robust zx1/sx1000 machvec support

Bjorn Helgaas:
      [IA64] Update default configs
      [IA64] ia64: add ar.k0 usage note
      [IA64] move ACPI IOSAPIC locality domain mapping from pci.c to acpi.c
      [IA64] respect ACPI producer/consumer flag for PCI root bridges

Bob Picco:
      V5 ia64 SPARSEMEM - Kconfig and Makefile
      V5 ia64 SPARSEMEM - eliminate contig_page_data
      V5 ia64 SPARSEMEM - conditional changes for SPARSEMEM
      V5 ia64 SPARSEMEM - SPARSEMEM code changes
      V5 ia64 SPARSEMEM - gensparse_defconfig

Bruce Losure:
      [IA64] Altix patch for fpga reset

Cliff Wickman:
      [IA64] ptrace - find memory sharers on children list

Dean Nelson:
      [IA64-SGI] get XPC to cleanly disengage from remote memory references
      [IA64-SGI] fixes for XPC disengage and open/close protocol
      [IA64-SGI] XPC changes to support more than 2k nasids
      [IA64-SGI] cleanup the way XPC locates the reserved page

Dean Roe:
      [IA64-SGI] Remove references to the SN bist_lock
      [IA64] - Avoid slow TLB purges on SGI Altix systems

H. J. Lu:
      [IA64] Fix 2.6 kernel for the new ia64 assembler

hawkes@sgi.com:
      [IA64] wider use of for_each_cpu_mask() in arch/ia64
      [IA64] another place to use for_each_cpu_mask() in arch/ia64

Jack Steiner:
      [IA64] Cleanup use of various #defines related to nodes
      [IA64] Increase max NR_CPUS on IA64 from 512 to 1024
      [IA64-SGI] Increase max system size of SGI SN systems

Khalid Aziz:
      [IA64] include EFI memory information in /proc/iomem

Mark Maule:
      [IA64-SGI] volatile semantics in places where it seems necessary
      [IA64-SGI] fix sn_pci_legacy_read/fix sn_pci_legacy_write

Peter Chubb:
      [IA64] Allow simulator to use bigger disks

Russ Anderson:
      [IA64-SGI] fix bte_copy() calling get_nasid() while preemptible

Siddha, Suresh B:
      [IA64] fix siblings field value in /proc/cpuinfo

Tony Luck:
      [IA64] simplified efi memory map parsing
      [IA64] Need to include <asm/sn/io.h> in a few more places.
      [IA64] Two more uses of cpuid_to_cnodeid() must go.
      [IA64] end of kernel 'data' is at _end, not _edata
      [IA64] fix warning unused variable `g'

