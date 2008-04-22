From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Apr 2008 23:36:36 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC012AF66F@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/Kconfig                                  |   11 -
 arch/ia64/kernel/crash.c                           |    4 +-
 arch/ia64/kernel/entry.S                           |    1 +
 arch/ia64/kernel/mca.c                             |   77 ++--
 arch/ia64/kernel/perfmon.c                         |    4 +-
 arch/ia64/sn/kernel/Makefile                       |    7 +-
 arch/ia64/sn/kernel/huberror.c                     |    4 +-
 arch/ia64/sn/pci/tioce_provider.c                  |    6 +-
 drivers/misc/Kconfig                               |   12 +
 drivers/misc/Makefile                              |    1 +
 drivers/misc/sgi-xp/Makefile                       |   11 +
 {include/asm-ia64/sn => drivers/misc/sgi-xp}/xp.h  |   94 ++---
 .../sn/kernel => drivers/misc/sgi-xp}/xp_main.c    |  141 +++---
 .../sn/kernel => drivers/misc/sgi-xp}/xp_nofault.S |    3 +-
 {include/asm-ia64/sn => drivers/misc/sgi-xp}/xpc.h |  500 ++++++++-----------
 .../kernel => drivers/misc/sgi-xp}/xpc_channel.c   |  528 ++++++++------------
 .../sn/kernel => drivers/misc/sgi-xp}/xpc_main.c   |  432 ++++++----------
 .../kernel => drivers/misc/sgi-xp}/xpc_partition.c |  409 +++++++---------
 .../ia64/sn/kernel => drivers/misc/sgi-xp}/xpnet.c |  139 ++----
 include/asm-ia64/mca.h                             |    1 +
 20 files changed, 965 insertions(+), 1420 deletions(-)
 create mode 100644 drivers/misc/sgi-xp/Makefile
 rename {include/asm-ia64/sn => drivers/misc/sgi-xp}/xp.h (91%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xp_main.c (69%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xp_nofault.S (95%)
 rename {include/asm-ia64/sn => drivers/misc/sgi-xp}/xpc.h (75%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xpc_channel.c (87%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xpc_main.c (82%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xpc_partition.c (79%)
 rename {arch/ia64/sn/kernel => drivers/misc/sgi-xp}/xpnet.c (89%)

Dean Nelson (4):
      [IA64] move XP and XPC to drivers/misc/sgi-xp
      [IA64] run some drivers/misc/sgi-xp through scripts/Lindent
      [IA64] run rest drivers/misc/sgi-xp through scripts/Lindent
      [IA64] run drivers/misc/sgi-xp through scripts/checkpatch.pl

Hidetoshi Seto (3):
      [IA64] disable interrupts on exit of ia64_trace_syscall
      [IA64] do notify DIE_MCA_MONARCH_PROCESS for each monarchs
      [IA64] simplify notify hooks in mca.c

Jeff Garzik (1):
      [IA64] minor irq handler cleanups



