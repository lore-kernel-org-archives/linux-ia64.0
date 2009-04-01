From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Apr 2009 20:20:54 +0000
Subject: [git pull] ia64 changes
Message-Id: <49d3cca614374c8bbd@agluck-desktop.sc.intel.com>
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

 arch/ia64/include/asm/intrinsics.h        |    6 +-
 arch/ia64/include/asm/mmu_context.h       |    6 +-
 arch/ia64/include/asm/module.h            |    6 +
 arch/ia64/include/asm/native/inst.h       |   13 +
 arch/ia64/include/asm/native/patchlist.h  |   38 ++
 arch/ia64/include/asm/native/pvchk_inst.h |    8 +
 arch/ia64/include/asm/paravirt.h          |   65 +++
 arch/ia64/include/asm/paravirt_patch.h    |  143 +++++
 arch/ia64/include/asm/paravirt_privop.h   |  365 +++++++++++++-
 arch/ia64/include/asm/smp.h               |    3 +-
 arch/ia64/include/asm/timex.h             |    1 +
 arch/ia64/include/asm/topology.h          |    5 -
 arch/ia64/include/asm/xen/hypervisor.h    |   39 +-
 arch/ia64/include/asm/xen/inst.h          |   28 +
 arch/ia64/include/asm/xen/interface.h     |    9 +
 arch/ia64/include/asm/xen/minstate.h      |   11 +-
 arch/ia64/include/asm/xen/patchlist.h     |   38 ++
 arch/ia64/include/asm/xen/privop.h        |    8 +-
 arch/ia64/kernel/Makefile                 |   39 +--
 arch/ia64/kernel/Makefile.gate            |   27 +
 arch/ia64/kernel/acpi.c                   |    8 +-
 arch/ia64/kernel/asm-offsets.c            |    2 +
 arch/ia64/kernel/efi.c                    |    1 +
 arch/ia64/kernel/entry.S                  |    4 +-
 arch/ia64/kernel/fsys.S                   |   35 +-
 arch/ia64/kernel/gate.S                   |  171 ++++---
 arch/ia64/kernel/gate.lds.S               |   17 +-
 arch/ia64/kernel/head.S                   |   10 +-
 arch/ia64/kernel/ivt.S                    |    2 +-
 arch/ia64/kernel/mca.c                    |    6 +-
 arch/ia64/kernel/module.c                 |   35 ++-
 arch/ia64/kernel/paravirt.c               |  539 +++++++++++++++++++-
 arch/ia64/kernel/paravirt_patch.c         |  514 ++++++++++++++++++
 arch/ia64/kernel/paravirt_patchlist.c     |   79 +++
 arch/ia64/kernel/paravirt_patchlist.h     |   28 +
 arch/ia64/kernel/paravirtentry.S          |   99 +++-
 arch/ia64/kernel/patch.c                  |   40 ++-
 arch/ia64/kernel/perfmon.c                |    4 +-
 arch/ia64/kernel/salinfo.c                |    6 +-
 arch/ia64/kernel/setup.c                  |    9 +-
 arch/ia64/kernel/smp.c                    |    6 +-
 arch/ia64/kernel/smpboot.c                |   17 +-
 arch/ia64/kernel/time.c                   |    9 +
 arch/ia64/kernel/vmlinux.lds.S            |   30 ++
 arch/ia64/kvm/kvm-ia64.c                  |    2 +-
 arch/ia64/kvm/vcpu.c                      |    2 +-
 arch/ia64/kvm/vtlb.c                      |    2 +
 arch/ia64/mm/init.c                       |   12 +-
 arch/ia64/mm/tlb.c                        |    2 +-
 arch/ia64/scripts/pvcheck.sed             |    1 +
 arch/ia64/sn/kernel/io_common.c           |   15 +-
 arch/ia64/sn/kernel/io_init.c             |   12 +-
 arch/ia64/sn/kernel/setup.c               |    5 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c         |   12 +-
 arch/ia64/sn/kernel/sn2/sn_hwperf.c       |    8 +-
 arch/ia64/sn/pci/pcibr/pcibr_dma.c        |    4 +-
 arch/ia64/xen/Makefile                    |   19 +-
 arch/ia64/xen/gate-data.S                 |    3 +
 arch/ia64/xen/hypercall.S                 |    2 +
 arch/ia64/xen/time.c                      |   48 ++
 arch/ia64/xen/xen_pv_ops.c                |  800 ++++++++++++++++++++++++++++-
 61 files changed, 3188 insertions(+), 290 deletions(-)
 create mode 100644 arch/ia64/include/asm/native/patchlist.h
 create mode 100644 arch/ia64/include/asm/paravirt_patch.h
 create mode 100644 arch/ia64/include/asm/xen/patchlist.h
 create mode 100644 arch/ia64/kernel/Makefile.gate
 create mode 100644 arch/ia64/kernel/paravirt_patch.c
 create mode 100644 arch/ia64/kernel/paravirt_patchlist.c
 create mode 100644 arch/ia64/kernel/paravirt_patchlist.h
 create mode 100644 arch/ia64/xen/gate-data.S

Isaku Yamahata (22):
      ia64/pv_ops/xen: use __initconst instead of __initdata for const data
      ia64/xen: short-circuit tests for dom0
      ia64/pv_ops: add hooks to paravirtualize fsyscall implementation.
      ia64/pv_ops/xen: preliminary to paravirtualizing fsys.S for xen.
      ia64/pv_ops: paravirtualize fsys.S.
      ia64/pv_ops/pvchecker: support mov = ar.itc paravirtualization
      ia64/pv_ops: paravirtualize mov = ar.itc.
      ia64/pv_ops/xen: paravirtualize read/write ar.itc and ar.itm
      ia64/pv_ops/pv_time_ops: add sched_clock hook.
      ia64/pv_ops/xen/pv_time_ops: implement sched_clock.
      ia64/pv_ops: gate page paravirtualization.
      ia64/pv_ops/xen: define xen specific gate page.
      ia64/pv_ops: move down __kernel_syscall_via_epc.
      ia64/pv_ops: paravirtualize gate.S.
      ia64/pv_ops/xen/gate.S: xen gate page paravirtualization
      ia64/pv_op/binarypatch: add helper functions to support binary patching for paravirt_ops.
      ia64/pv_ops: implement binary patching optimization for native.
      ia64/pv_ops/bp/module: support binary patching for kernel module.
      ia64/pv_ops/binary patch: define paravirt_dv_serialize_data() and suppress false positive warning.
      ia64/pv_ops/bp/xen: implemented binary patchable pv_cpu_ops.
      ia64/xen: fix the link error.
      ia64: remove some warnings.

Randy Dunlap (1):
      [IA64] Fix typo/thinko in arch/ia64/sn/kernel/sn2/sn2_smp.c

Rusty Russell (5):
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): ia64
      cpumask: arch_send_call_function_ipi_mask: ia64
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_bits.: ia64
      cpumask: Use accessors code.: ia64
      cpumask: use mm_cpumask() wrapper: ia64

Stoyan Gaydarov (1):
      [IA64] BUG to BUG_ON changes

