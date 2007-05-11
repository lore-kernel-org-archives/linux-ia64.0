From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 May 2007 18:09:38 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01749603@scsmsx411.amr.corp.intel.com>
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

The change to kernel/irq/proc.c just adds an arch hook to allow
validation of the new cpumask.  SGI sn2 systems can only select
a single target processor. Andrew Morton came up with the idiom
used there that avoids yet another ARCH_HAS_... define.

Thanks!

-Tony

 arch/ia64/Kconfig                   |    4 +
 arch/ia64/hp/common/hwsw_iommu.c    |    2 
 arch/ia64/kernel/entry.S            |    2 
 arch/ia64/kernel/err_inject.c       |    2 
 arch/ia64/kernel/irq.c              |   11 ++++
 arch/ia64/kernel/kprobes.c          |   12 +++--
 arch/ia64/kernel/machvec.c          |    2 
 arch/ia64/kernel/mca.c              |    2 
 arch/ia64/mm/contig.c               |    2 
 arch/ia64/mm/discontig.c            |    2 
 arch/ia64/mm/init.c                 |   51 ----------------------
 arch/ia64/sn/kernel/io_common.c     |    2 
 arch/ia64/sn/kernel/xpc_partition.c |    2 
 arch/ia64/sn/kernel/xpnet.c         |    4 -
 drivers/char/snsc_event.c           |    2 
 drivers/pci/hotplug/sgi_hotplug.c   |   36 +++++++--------
 include/asm-ia64/irq.h              |    6 ++
 include/asm-ia64/kprobes.h          |    4 +
 include/asm-ia64/pgalloc.h          |   82 +++++++-----------------------------
 include/asm-ia64/unistd.h           |    4 +
 kernel/irq/proc.c                   |    7 +++
 21 files changed, 89 insertions(+), 152 deletions(-)

Anil S Keshavamurthy (1):
      [IA64] fix Kprobes reentrancy

Christoph Lameter (1):
      [IA64] Quicklist support for IA64

John Keller (1):
      [IA64] SN: validate smp_affinity mask on intr redirect

Tony Luck (7):
      [IA64] typo s/kenrel/kernel/
      [IA64] Fix warnings resulting from type-checking in dev_dbg()
      [IA64] Wire up epoll_pwait and utimensat
      [IA64] more warning cleanups
      [IA64] Fix - Section mismatch: reference to .init.data:mvec_name
      [IA64] mca.c:121: warning: 'cpe_poll_timer' defined but not used
      [IA64] drivers/char/snsc_event.c:206: warning: unused variable `p'
