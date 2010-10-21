From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Oct 2010 16:00:24 +0000
Subject: [git pull] ia64 changes
Message-Id: <4cc06398282628127b@agluck-desktop.sc.intel.com>
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

Peer with extra suspicion at the octo-merge since this is the first
time I've used one of these to pull in all my topic branches.  I just
ran:
 $ git merge release drop_do_IRQ fix_early_irq misc-2.6.37 next-fixes optimize-unwind remove-compat-h stack_trace

Thanks!

-Tony

 arch/ia64/Kconfig                   |   12 ++-
 arch/ia64/include/asm/compat.h      |  208 -----------------------------------
 arch/ia64/include/asm/hardirq.h     |   11 +-
 arch/ia64/include/asm/iommu_table.h |    6 +
 arch/ia64/kernel/Makefile           |    1 +
 arch/ia64/kernel/cyclone.c          |    2 +-
 arch/ia64/kernel/iosapic.c          |   60 ++---------
 arch/ia64/kernel/irq_ia64.c         |    5 +
 arch/ia64/kernel/mca.c              |   38 +++---
 arch/ia64/kernel/palinfo.c          |    2 +-
 arch/ia64/kernel/perfmon.c          |   12 +-
 arch/ia64/kernel/salinfo.c          |    2 +-
 arch/ia64/kernel/setup.c            |    4 -
 arch/ia64/kernel/stacktrace.c       |   39 +++++++
 arch/ia64/kernel/unwind.c           |   23 +++-
 arch/ia64/xen/xen_pv_ops.c          |    5 +-
 drivers/serial/ioc3_serial.c        |    4 +
 17 files changed, 128 insertions(+), 306 deletions(-)
 delete mode 100644 arch/ia64/include/asm/compat.h
 create mode 100644 arch/ia64/include/asm/iommu_table.h
 create mode 100644 arch/ia64/kernel/stacktrace.c

FUJITA Tomonori (1):
      [IA64] enable ARCH_DMA_ADDR_T_64BIT

Joe Perches (2):
      [IA64] Use static const char * const in palinfo.c
      [IA64] Remove unnecessary casts of private_data in perfmon.c

Julia Lawall (1):
      [IA64] Fix missing iounmap in error path in cyclone.c

Konrad Rzeszutek Wilk (1):
      [IA64] iommu: Add a dummy iommu_table.h file in IA64.

Nikitas Angelinas (1):
      [IA64] xen: use ARRAY_SIZE macro in xen_pv_ops.c

Phil Carmody (2):
      [IA64] unwind: remove preprocesser noise, and correct comment
      [IA64] unwind - optimise linked-list searches for modules

Rahul Ruikar (1):
      [IA64] ioc3_serial: release resources in error return path

Thomas Gleixner (1):
      [IA64] salinfo: sema_init instead of init_MUTEX

Tony Luck (6):
      [IA64] Move local_softirq_pending() definition
      [IA64] Add CONFIG_STACKTRACE_SUPPORT
      [IA64] remove asm/compat.h
      [IA64] Stop using the deprecated __do_IRQ() code path
      [IA64] Initialize interrupts later (from init_IRQ())
      [IA64] Cannot use register_percpu_irq() from ia64_mca_init()

