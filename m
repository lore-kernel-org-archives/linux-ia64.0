From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Feb 2008 18:10:40 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC812F9E@orsmsx424.amr.corp.intel.com>
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

 Documentation/ia64/aliasing-test.c    |   15 +-
 MAINTAINERS                           |    9 +
 arch/ia64/hp/common/sba_iommu.c       |    2 +-
 arch/ia64/ia32/ia32_support.c         |    5 +-
 arch/ia64/kernel/efi.c                |  502 ++++++++++++++++++---------------
 arch/ia64/kernel/fsyscall_gtod_data.h |    4 +-
 arch/ia64/kernel/ia64_ksyms.c         |    3 +
 arch/ia64/kernel/kprobes.c            |    7 +-
 arch/ia64/kernel/mca.c                |   66 +++--
 arch/ia64/kernel/mca_asm.S            |   46 ++--
 arch/ia64/kernel/mca_drv.c            |    2 +-
 arch/ia64/kernel/mca_drv.h            |    2 +-
 arch/ia64/kernel/mca_drv_asm.S        |    2 +-
 arch/ia64/kernel/perfmon.c            |    6 +-
 arch/ia64/kernel/sal.c                |   14 +
 arch/ia64/kernel/setup.c              |    2 +-
 arch/ia64/kernel/smpboot.c            |   11 -
 arch/ia64/kernel/traps.c              |   35 ++-
 arch/ia64/kernel/unaligned.c          |   13 +-
 arch/ia64/mm/fault.c                  |    8 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c     |    2 +-
 arch/ia64/sn/kernel/sn2/sn_hwperf.c   |   11 +-
 include/asm-ia64/bitops.h             |   50 ++--
 include/asm-ia64/gcc_intrin.h         |    2 +
 include/asm-ia64/mca.h                |    6 +-
 include/asm-ia64/mca_asm.h            |    3 +-
 include/asm-ia64/processor.h          |    2 +-
 include/asm-ia64/sal.h                |   14 +-
 28 files changed, 468 insertions(+), 376 deletions(-)

Aron Griffis (3):
      [IA64] Make efi.c mostly fit in 80 columns
      [IA64] efi.c Spelling/punctuation fixes
      [IA64] efi.c Add /* never reached */ annotation

Daniel Walker (1):
      [IA64] sn_hwperf semaphore to mutex

Doug Chapman (1):
      [IA64] fix userspace compile error in gcc_intrin.h

Hidetoshi Seto (2):
      [IA64] generalize attribute of fsyscall_gtod_data
      [IA64] mca style cleanup

Jan Beulich (2):
      [IA64] remove dead code: __cpu_{down,die} from !HOTPLUG_CPU
      [IA64] honor notify_die() returning NOTIFY_STOP

Jan Engelhardt (1):
      [IA64] constify function pointer tables

Masami Hiramatsu (1):
      [IA64] Fix the order of atomic operations in restore_previous_kprobes on ia64

Pavel Emelyanov (1):
      [IA64] make pfm_get_task work with virtual pids

Randy Dunlap (1):
      [IA64] aliasing-test: fix gcc warnings on non-ia64

Xiantao Zhang (1):
      [IA64] ia64_set_psr should use srlz.i

Zhang Xiantao (1):
      [IA64] Appoint kvm/ia64 Maintainers

Zhang, Xiantao (1):
      [IA64] Export three symbols for module use

Zoltan Menyhart (1):
      [IA64] Slim-down __clear_bit_unlock



