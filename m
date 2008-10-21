From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Oct 2008 18:01:18 +0000
Subject: [git pull] ia64 changes
Message-Id: <200810211801.m9LI1IMQ026467@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
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

 Documentation/ia64/xen.txt                         |  183 ++++++++
 arch/ia64/Kconfig                                  |   50 +++
 arch/ia64/Makefile                                 |    3 +
 arch/ia64/configs/generic_defconfig                |    2 +
 arch/ia64/configs/tiger_defconfig                  |    2 +
 arch/ia64/dig/Makefile                             |    5 +
 arch/ia64/dig/dig_vtd_iommu.c                      |   59 +++
 arch/ia64/dig/machvec_vtd.c                        |    3 +
 arch/ia64/ia32/ia32_entry.S                        |   11 +-
 arch/ia64/ia32/sys_ia32.c                          |  106 +-----
 arch/ia64/include/asm/break.h                      |    9 +
 arch/ia64/include/asm/cacheflush.h                 |    2 +
 arch/ia64/include/asm/device.h                     |    3 +
 arch/ia64/include/asm/dma-mapping.h                |   50 +++
 arch/ia64/include/asm/iommu.h                      |   16 +
 arch/ia64/include/asm/kregs.h                      |    2 +-
 arch/ia64/include/asm/machvec.h                    |    4 +
 arch/ia64/include/asm/machvec_dig_vtd.h            |   38 ++
 arch/ia64/include/asm/machvec_init.h               |    1 +
 arch/ia64/include/asm/machvec_xen.h                |   22 +
 arch/ia64/include/asm/meminit.h                    |    3 +-
 arch/ia64/include/asm/native/inst.h                |   10 +-
 arch/ia64/include/asm/native/pvchk_inst.h          |  263 +++++++++++
 arch/ia64/include/asm/paravirt.h                   |    4 +-
 arch/ia64/include/asm/pci.h                        |    3 +
 arch/ia64/include/asm/ptrace.h                     |    8 +
 arch/ia64/include/asm/pvclock-abi.h                |   48 ++
 arch/ia64/include/asm/swiotlb.h                    |   56 +++
 arch/ia64/include/asm/sync_bitops.h                |   51 +++
 arch/ia64/include/asm/syscall.h                    |  163 +++++++
 arch/ia64/include/asm/thread_info.h                |    3 -
 arch/ia64/include/asm/timex.h                      |    2 +
 arch/ia64/include/asm/unistd.h                     |    1 +
 .../paravirt_inst.h => include/asm/xen/events.h}   |   35 ++-
 .../asm/xen/grant_table.h}                         |   14 +-
 arch/ia64/include/asm/xen/hypercall.h              |  265 +++++++++++
 arch/ia64/include/asm/xen/hypervisor.h             |   89 ++++
 arch/ia64/include/asm/xen/inst.h                   |  458 ++++++++++++++++++++
 arch/ia64/include/asm/xen/interface.h              |  346 +++++++++++++++
 arch/ia64/include/asm/xen/irq.h                    |   44 ++
 arch/ia64/include/asm/xen/minstate.h               |  134 ++++++
 arch/ia64/include/asm/xen/page.h                   |   65 +++
 arch/ia64/include/asm/xen/privop.h                 |  129 ++++++
 arch/ia64/include/asm/xen/xcom_hcall.h             |   51 +++
 arch/ia64/include/asm/xen/xencomm.h                |   42 ++
 arch/ia64/kernel/Makefile                          |   22 +
 arch/ia64/kernel/acpi.c                            |   22 +
 arch/ia64/kernel/asm-offsets.c                     |   31 ++
 arch/ia64/kernel/entry.S                           |    5 +
 arch/ia64/kernel/ivt.S                             |    6 +-
 arch/ia64/kernel/msi_ia64.c                        |   80 ++++
 arch/ia64/kernel/nr-irqs.c                         |    1 +
 arch/ia64/kernel/paravirt.c                        |    2 +-
 arch/ia64/kernel/paravirt_inst.h                   |    4 +-
 arch/ia64/kernel/pci-dma.c                         |  129 ++++++
 arch/ia64/kernel/pci-swiotlb.c                     |   46 ++
 arch/ia64/kernel/perfmon.c                         |    7 +-
 arch/ia64/kernel/process.c                         |   22 +-
 arch/ia64/kernel/ptrace.c                          |  112 ++++--
 arch/ia64/kernel/setup.c                           |   42 ++-
 arch/ia64/kernel/signal.c                          |    8 +
 arch/ia64/lib/flush.S                              |   55 +++
 arch/ia64/mm/tlb.c                                 |    8 +-
 arch/ia64/scripts/pvcheck.sed                      |   32 ++
 arch/ia64/xen/Kconfig                              |   26 ++
 arch/ia64/xen/Makefile                             |   22 +
 arch/ia64/xen/grant-table.c                        |  155 +++++++
 arch/ia64/xen/hypercall.S                          |   91 ++++
 arch/ia64/xen/hypervisor.c                         |   96 ++++
 arch/ia64/xen/irq_xen.c                            |  435 +++++++++++++++++++
 .../ia64/{kernel/paravirt_inst.h => xen/irq_xen.h} |   19 +-
 arch/ia64/xen/machvec.c                            |    4 +
 .../ia64/{kernel/paravirt_inst.h => xen/suspend.c} |   49 ++-
 arch/ia64/xen/time.c                               |  213 +++++++++
 arch/ia64/{kernel/paravirt_inst.h => xen/time.h}   |   11 +-
 arch/ia64/xen/xcom_hcall.c                         |  441 +++++++++++++++++++
 arch/ia64/xen/xen_pv_ops.c                         |  364 ++++++++++++++++
 arch/ia64/xen/xencomm.c                            |  105 +++++
 arch/ia64/xen/xenivt.S                             |   52 +++
 arch/ia64/xen/xensetup.S                           |   83 ++++
 80 files changed, 5437 insertions(+), 221 deletions(-)
 create mode 100644 Documentation/ia64/xen.txt
 create mode 100644 arch/ia64/dig/dig_vtd_iommu.c
 create mode 100644 arch/ia64/dig/machvec_vtd.c
 create mode 100644 arch/ia64/include/asm/iommu.h
 create mode 100644 arch/ia64/include/asm/machvec_dig_vtd.h
 create mode 100644 arch/ia64/include/asm/machvec_xen.h
 create mode 100644 arch/ia64/include/asm/native/pvchk_inst.h
 create mode 100644 arch/ia64/include/asm/pvclock-abi.h
 create mode 100644 arch/ia64/include/asm/swiotlb.h
 create mode 100644 arch/ia64/include/asm/sync_bitops.h
 create mode 100644 arch/ia64/include/asm/syscall.h
 copy arch/ia64/{kernel/paravirt_inst.h => include/asm/xen/events.h} (61%)
 copy arch/ia64/{kernel/paravirt_inst.h => include/asm/xen/grant_table.h} (77%)
 create mode 100644 arch/ia64/include/asm/xen/hypercall.h
 create mode 100644 arch/ia64/include/asm/xen/hypervisor.h
 create mode 100644 arch/ia64/include/asm/xen/inst.h
 create mode 100644 arch/ia64/include/asm/xen/interface.h
 create mode 100644 arch/ia64/include/asm/xen/irq.h
 create mode 100644 arch/ia64/include/asm/xen/minstate.h
 create mode 100644 arch/ia64/include/asm/xen/page.h
 create mode 100644 arch/ia64/include/asm/xen/privop.h
 create mode 100644 arch/ia64/include/asm/xen/xcom_hcall.h
 create mode 100644 arch/ia64/include/asm/xen/xencomm.h
 create mode 100644 arch/ia64/kernel/pci-dma.c
 create mode 100644 arch/ia64/kernel/pci-swiotlb.c
 create mode 100644 arch/ia64/scripts/pvcheck.sed
 create mode 100644 arch/ia64/xen/Kconfig
 create mode 100644 arch/ia64/xen/Makefile
 create mode 100644 arch/ia64/xen/grant-table.c
 create mode 100644 arch/ia64/xen/hypercall.S
 create mode 100644 arch/ia64/xen/hypervisor.c
 create mode 100644 arch/ia64/xen/irq_xen.c
 copy arch/ia64/{kernel/paravirt_inst.h => xen/irq_xen.h} (73%)
 create mode 100644 arch/ia64/xen/machvec.c
 copy arch/ia64/{kernel/paravirt_inst.h => xen/suspend.c} (64%)
 create mode 100644 arch/ia64/xen/time.c
 copy arch/ia64/{kernel/paravirt_inst.h => xen/time.h} (83%)
 create mode 100644 arch/ia64/xen/xcom_hcall.c
 create mode 100644 arch/ia64/xen/xen_pv_ops.c
 create mode 100644 arch/ia64/xen/xencomm.c
 create mode 100644 arch/ia64/xen/xenivt.S
 create mode 100644 arch/ia64/xen/xensetup.S

Christoph Hellwig (2):
      [IA64] remove sys32_pause
      [IA64] kill sys32_pipe

Fenghua Yu (1):
      [IA64] Add Variable Page Size and IA64 Support in Intel IOMMU

Isaku Yamahata (33):
      ia64/pv_ops: fix paravirtualization of ivt.S with CONFIG_SMP=n
      ia64/pv_ops: avoid name conflict of get_irq_chip().
      ia64/pv_ops: update native/inst.h to clobber predicate.
      ia64: move function declaration, ia64_cpu_local_tick() from .c to .h
      ia64/xen: reserve "break" numbers used for xen hypercalls.
      ia64/xen: introduce sync bitops which is necessary for ia64/xen support.
      ia64/xen: increase IA64_MAX_RSVD_REGIONS.
      ia64/xen: introduce definitions necessary for ia64/xen hypercalls.
      ia64/xen: define several constants for ia64/xen.
      ia64/xen: add a necessary header file to compile include/xen/interface/xen.h
      ia64/xen: define helper functions for xen related address conversion.
      ia64/xen: define helper functions for xen hypercalls.
      ia64/xen: implement the arch specific part of xencomm.
      ia64/xen: xencomm conversion functions for hypercalls
      ia64/xen: implement arch specific part of xen grant table.
      ia64/xen: add definitions necessary for xen event channel.
      ia64/xen: introduce helper function to identify domain mode.
      ia64/pv_ops/xen: elf note based xen startup.
      ia64/pv_ops/xen: define xen pv_init_ops for various xen initialization.
      ia64/pv_ops/xen: define xen pv_cpu_ops.
      ia64/pv_ops/xen: define xen paravirtualized instructions for hand written assembly code
      ia64/pv_ops/xen: paravirtualize DO_SAVE_MIN for xen.
      ia64/pv_ops/xen: paravirtualize ivt.S for xen.
      ia64/pv_ops/xen: paravirtualize entry.S for ia64/xen.
      ia64/pv_ops/xen: implement xen pv_iosapic_ops.
      ia64/pv_ops/xen: define the nubmer of irqs which xen needs.
      ia64/pv_ops/xen: implement xen pv_irq_ops.
      ia64/pv_ops/xen: implement xen pv_time_ops.
      ia64/xen: define xen machine vector for domU.
      ia64/xen: preliminary support for save/restore.
      ia64/pv_ops: update Kconfig for paravirtualized guest and xen.
      ia64/xen: a recipe for using xen/ia64 with pv_ops.
      ia64/pv_ops: paravirtualized instruction checker.

Shaohua Li (4):
      [IA64] utrace syscall.h support for ia64
      [IA64] utrace use generic trace hook
      [IA64] utrace Enable trace hook config
      [IA64] utrace Convert compat ptrace to use compat_sys_ptrace

Tony Luck (1):
      [IA64] Fix annoying IA64_TR_ALLOC_MAX message.

