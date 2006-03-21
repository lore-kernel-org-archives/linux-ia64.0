From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Mar 2006 18:55:36 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200603211855.k2LItaIp005043@agluck-lia64.sc.intel.com>
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

This will update the files shown below.  These are the patches that have been
cooking in -mm.

Thanks!

-Tony

 arch/ia64/Kconfig                   |   19 ++
 arch/ia64/configs/tiger_defconfig   |    2 
 arch/ia64/kernel/acpi.c             |   14 +
 arch/ia64/kernel/entry.S            |   14 -
 arch/ia64/kernel/iosapic.c          |   10 -
 arch/ia64/kernel/irq.c              |   13 +
 arch/ia64/kernel/mca.c              |   90 ++++++---
 arch/ia64/kernel/perfmon.c          |    5 
 arch/ia64/kernel/signal.c           |  101 -----------
 arch/ia64/kernel/smpboot.c          |  114 +++++++++++-
 arch/ia64/kernel/time.c             |    9 
 arch/ia64/kernel/topology.c         |    2 
 arch/ia64/mm/contig.c               |    4 
 arch/ia64/mm/discontig.c            |    9 
 arch/ia64/sn/kernel/Makefile        |    3 
 arch/ia64/sn/kernel/pio_phys.S      |   71 +++++++
 arch/ia64/sn/kernel/setup.c         |    6 
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |   23 ++
 arch/ia64/sn/kernel/xpc_channel.c   |  102 ++++++-----
 arch/ia64/sn/kernel/xpc_main.c      |    1 
 arch/ia64/sn/kernel/xpc_partition.c |   28 ++-
 arch/ia64/sn/pci/tioce_provider.c   |  326 +++++++++++++++++++++++++++++++++---
 drivers/char/snsc.h                 |    5 
 drivers/char/snsc_event.c           |   32 ++-
 drivers/sn/ioc4.c                   |   41 +---
 include/asm-ia64/intel_intrin.h     |  134 +-------------
 include/asm-ia64/machvec.h          |   13 +
 include/asm-ia64/machvec_sn2.h      |    4 
 include/asm-ia64/mca.h              |    2 
 include/asm-ia64/mutex.h            |   93 +++++++++-
 include/asm-ia64/processor.h        |    3 
 include/asm-ia64/signal.h           |    2 
 include/asm-ia64/sn/addrs.h         |    8 
 include/asm-ia64/sn/rw_mmr.h        |   56 ------
 include/asm-ia64/sn/tioce.h         |   36 +++
 include/asm-ia64/sn/xpc.h           |   22 --
 include/asm-ia64/system.h           |    7 
 include/asm-ia64/thread_info.h      |   12 -
 38 files changed, 955 insertions(+), 481 deletions(-)

Aaron Young:
      [IA64-SGI] Handle SC env. powerdown events

Ashok Raj:
      [IA64] support for cpu0 removal
      [IA64] Fix UP build with BSP removal support.

Brent Casavant:
      [IA64] hooks to wait for mmio writes to drain when migrating processes

Chen, Kenneth W:
      [IA64] implement ia64 specific mutex primitives
      [IA64] map ia64_hint definition to intel compiler intrinsic
      [IA64] clean up asm/intel_intrin.h
      [IA64] add __builtin_trap definition for icc build
      [IA64] use icc defined constant

Jack Steiner:
      [IA64-SGI] - Eliminate SN pio_phys_xxx macros. Move to assembly

Jes Sorensen:
      [IA64-SGI] sem2mutex ioc4.c
      [IA64-SGI] SN2-XP reduce kmalloc wrapper inlining

Keith Owens:
      [IA64] Delete MCA/INIT sigdelayed code
      [IA64] MCA: print messages in MCA handler
      [IA64] MCA: update MCA comm field for user space tasks
      [IA64] MCA: remove obsolete ifdef

Mark Maule:
      [IA64-SGI] driver bugfixes and hardware workarounds for CE1.0 asic

Tony Luck:
      Pull bsp-removal into release branch
      Pull delete-sigdelayed into release branch
      Pull sn2-mmio-writes into release branch
      Pull mca-cleanup into release branch

