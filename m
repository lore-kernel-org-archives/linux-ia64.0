From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 20 Jul 2007 18:54:06 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01FA497C@scsmsx411.amr.corp.intel.com>
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

This will update the files shown below.  I'm touching a few
non-ia64 files (they are at the bottom of the diffstat) in here
to delete the CONFIG_TIME_INTERPOLATION code that nobody except
ia64 used.

Thanks!

-Tony

 Documentation/time_interpolators.txt  |   40 -
 Documentation/kernel-parameters.txt   |    5 
 arch/ia64/Kconfig                     |    6 
 arch/ia64/configs/bigsur_defconfig    |    2 
 arch/ia64/configs/gensparse_defconfig |    2 
 arch/ia64/configs/sim_defconfig       |    2 
 arch/ia64/configs/sn2_defconfig       |    2 
 arch/ia64/configs/tiger_defconfig     |  322 +++---------
 arch/ia64/configs/zx1_defconfig       |    2 
 arch/ia64/defconfig                   |  338 ++++---------
 arch/ia64/kernel/asm-offsets.c        |   35 -
 arch/ia64/kernel/cyclone.c            |   46 +
 arch/ia64/kernel/entry.S              |    2 
 arch/ia64/kernel/fsys.S               |  179 +++---
 arch/ia64/kernel/fsyscall_gtod_data.h |   23 
 arch/ia64/kernel/iosapic.c            |  872 +++++++++++++++-------------------
 arch/ia64/kernel/irq.c                |    2 
 arch/ia64/kernel/irq_ia64.c           |  391 ++++++++++++---
 arch/ia64/kernel/msi_ia64.c           |   29 -
 arch/ia64/kernel/smpboot.c            |    4 
 arch/ia64/kernel/time.c               |   96 +++
 arch/ia64/sn/kernel/sn2/timer.c       |   29 -
 drivers/acpi/processor_idle.c         |    4 
 drivers/char/hpet.c                   |   70 +-
 include/asm-ia64/hw_irq.h             |   20 
 include/asm-ia64/iosapic.h            |    6 
 include/asm-ia64/irq.h                |    9 
 include/asm-ia64/rwsem.h              |    4 
 include/asm-ia64/unistd.h             |    2 
 include/linux/clocksource.h           |    6 
 include/linux/timex.h                 |   60 --
 kernel/time.c                         |   88 ---
 kernel/time/ntp.c                     |   10 
 kernel/time/timekeeping.c             |    4 
 kernel/timer.c                        |  188 -------
 35 files changed, 1338 insertions(+), 1562 deletions(-)

Bob Picco (1):
      [IA64] remove time interpolator

David Chinner (1):
      [IA64] fallocate system call

Robert P. J. Day (1):
      [IA64] Prevent people from directly including <asm/rwsem.h>.

Tony Luck (2):
      [IA64] refresh some config files for 64K pagesize
      [IA64] Convert to generic timekeeping/clocksource

Yasuaki Ishimatsu (13):
      [IA64] Remove block structure for locking in iosapic.c
      [IA64] Remove duplicated members in iosapic_rte_info
      [IA64] Cleanup lock order in iosapic_register_intr
      [IA64] Use per iosapic lock for indirect iosapic register access
      [IA64] Use dynamic irq for iosapic interrupts
      [IA64] Fix invalid irq vector assumption for iosapic
      [IA64] Check if irq is sharable
      [IA64] Add mapping table between irq and vector
      [IA64] Add support for vector domain
      [IA64] Support irq migration across domain
      [IA64] Enable percpu vector domain for IA64_GENERIC
      [IA64] Enable percpu vector domain for IA64_DIG
      [IA64] Delete iosapic_free_rte()
