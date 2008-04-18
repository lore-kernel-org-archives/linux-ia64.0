From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Apr 2008 16:34:33 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
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

 Documentation/kernel-parameters.txt |    4 +
 arch/ia64/Kconfig                   |   14 +
 arch/ia64/hp/common/sba_iommu.c     |   56 ++-
 arch/ia64/ia32/elfcore32.h          |   14 +-
 arch/ia64/ia32/sys_ia32.c           |  649 ++++++++++++++++++-
 arch/ia64/kernel/acpi.c             |    4 +-
 arch/ia64/kernel/asm-offsets.c      |   13 +
 arch/ia64/kernel/crash.c            |   56 +-
 arch/ia64/kernel/efi.c              |   46 ++
 arch/ia64/kernel/entry.S            |   65 ++
 arch/ia64/kernel/fsys.S             |   88 ++-
 arch/ia64/kernel/head.S             |   20 +
 arch/ia64/kernel/irq_ia64.c         |    2 +-
 arch/ia64/kernel/ivt.S              |   69 ++
 arch/ia64/kernel/kprobes.c          |  133 +++-
 arch/ia64/kernel/mca.c              |   60 ++-
 arch/ia64/kernel/mca_asm.S          |    5 +
 arch/ia64/kernel/minstate.h         |   14 +
 arch/ia64/kernel/numa.c             |    2 +-
 arch/ia64/kernel/patch.c            |    8 +-
 arch/ia64/kernel/perfmon.c          |    4 +-
 arch/ia64/kernel/process.c          |   30 -
 arch/ia64/kernel/ptrace.c           | 1217 +++++++++++++++++++++++++---------
 arch/ia64/kernel/setup.c            |   31 +-
 arch/ia64/kernel/smp.c              |   82 +++
 arch/ia64/kernel/smpboot.c          |    2 +-
 arch/ia64/kernel/time.c             |   78 +++
 arch/ia64/kernel/unaligned.c        |    3 +-
 arch/ia64/mm/contig.c               |    4 +-
 arch/ia64/mm/discontig.c            |   17 +-
 arch/ia64/mm/init.c                 |   14 +-
 arch/ia64/mm/numa.c                 |    4 +-
 arch/ia64/mm/tlb.c                  |  357 ++++++++++-
 arch/ia64/sn/kernel/xpc_main.c      |    8 +-
 arch/ia64/sn/kernel/xpc_partition.c |    2 +-
 include/asm-ia64/acpi.h             |   33 +
 include/asm-ia64/cputime.h          |  104 +++
 include/asm-ia64/elf.h              |   31 +-
 include/asm-ia64/kprobes.h          |    7 +-
 include/asm-ia64/kregs.h            |    3 +
 include/asm-ia64/meminit.h          |    3 +-
 include/asm-ia64/numa.h             |    2 +
 include/asm-ia64/pal.h              |   72 ++-
 include/asm-ia64/pgtable.h          |    2 +-
 include/asm-ia64/sal.h              |   21 +
 include/asm-ia64/smp.h              |    3 +
 include/asm-ia64/system.h           |   12 +
 include/asm-ia64/thread_info.h      |   14 +
 include/asm-ia64/tlb.h              |   26 +
 include/asm-ia64/tlbflush.h         |    1 +
 50 files changed, 2965 insertions(+), 544 deletions(-)

Alan D. Brunelle (1):
      [IA64] Fix unlock ordering in smp_callin

Christoph Lameter (1):
      [IA64] Untangle sync_icache_dcache() page size determination

FUJITA Tomonori (1):
      [IA64] make IOMMU respect the segment boundary limits

Fenghua Yu (2):
      [IA64] Multiple outstanding ptc.g instruction support
      [IA64] Kernel parameter for max number of concurrent global TLB purges

Hidetoshi Seto (4):
      [IA64] VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
      [IA64] cleanup and improve fsys_gettimeofday
      [IA64] kdump: add kdump_on_fatal_mca
      [IA64] kdump: crash.c coding style fix

Johannes Weiner (1):
      [IA64] remove redundant display of free swap space in show_mem()

KOSAKI Motohiro (1):
      [IA64] pgd_offset() constfication.

Li Zefan (1):
      [IA64] use goto to jump out do/while_each_thread

Masami Hiramatsu (1):
      [IA64] kprobes: kprobe-booster for ia64

Pavel Emelyanov (1):
      [IA64] fix getpid and set_tid_address fast system calls for pid namespaces

Robert P. J. Day (1):
      [IA64] Replace explicit jiffies tests with time_* macros.

Russ Anderson (1):
      [IA64] Itanium Spec updates

S.Caglar Onur (1):
      [IA64] arch/ia64/kernel/: use time_* macros

Shaohua Li (4):
      [IA64] regset: 64-bit support
      [IA64] regset: 32-bit support
      [IA64] use CORE_DUMP_USE_REGSET
      [IA64] remove duplicate code for register access

Takao Indoh (1):
      [IA64] kdump: Add crash_save_vmcoreinfo for INIT

Xiantao Zhang (2):
      [IA64] Add API for allocating Dynamic TR resource.
      [IA64] Implement smp_call_function_mask for ia64

Zoltan Menyhart (1):
      [IA64] Fix NUMA configuration issue

holt@sgi.com (2):
      [IA64] Correct pernodesize calculation.
      [IA64] Minimize per_cpu reservations.



