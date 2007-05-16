From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 May 2007 17:45:38 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01786470@scsmsx411.amr.corp.intel.com>
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

This will update the files shown below (most of which are part of Simon Arlott's
spelling patch which accounts for 30 files, 75 insertions, 75 deletions).

Thanks!

-Tony

 arch/ia64/kernel/acpi.c             |    2 -
 arch/ia64/kernel/crash.c            |   24 ++++++++++++++-------
 arch/ia64/kernel/entry.S            |    3 ++
 arch/ia64/kernel/irq.c              |    6 ++---
 arch/ia64/kernel/irq_lsapic.c       |    2 -
 arch/ia64/kernel/kprobes.c          |   15 +++----------
 arch/ia64/kernel/mca.c              |    5 +++-
 arch/ia64/kernel/mca_drv.c          |    4 +--
 arch/ia64/kernel/module.c           |    2 -
 arch/ia64/kernel/perfmon.c          |   18 +++++++--------
 arch/ia64/kernel/perfmon_mckinley.h |    2 -
 arch/ia64/kernel/sal.c              |    2 -
 arch/ia64/kernel/salinfo.c          |    2 -
 arch/ia64/kernel/setup.c            |    6 ++---
 arch/ia64/kernel/smp.c              |   12 +++++-----
 arch/ia64/kernel/smpboot.c          |    6 ++---
 arch/ia64/kernel/time.c             |    4 +--
 arch/ia64/kernel/traps.c            |    2 -
 arch/ia64/kernel/unwind.c           |    2 -
 arch/ia64/mm/discontig.c            |    2 -
 arch/ia64/mm/fault.c                |   41 ++++++++++++------------------------
 arch/ia64/sn/kernel/bte.c           |   12 +++++-----
 arch/ia64/sn/kernel/bte_error.c     |    4 +--
 arch/ia64/sn/kernel/io_common.c     |    2 -
 arch/ia64/sn/kernel/setup.c         |    2 -
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |    2 -
 arch/ia64/sn/kernel/xpc_channel.c   |    8 +++----
 arch/ia64/sn/kernel/xpnet.c         |    2 -
 arch/ia64/sn/pci/pci_dma.c          |    8 +++----
 arch/ia64/sn/pci/pcibr/pcibr_ate.c  |    6 ++---
 arch/ia64/sn/pci/pcibr/pcibr_dma.c  |    2 -
 arch/ia64/sn/pci/tioca_provider.c   |    6 ++---
 arch/ia64/sn/pci/tioce_provider.c   |   16 +++++++-------
 include/asm-ia64/kdebug.h           |   16 +++++++++++---
 include/asm-ia64/kprobes.h          |    1 
 include/asm-ia64/unistd.h           |    5 +++-
 36 files changed, 131 insertions(+), 123 deletions(-)

Christoph Hellwig (1):
      [IA64] optimize pagefaults a little

Jay Lan (1):
      [IA64] kdump on INIT needs multi-nodes sync-up (v.2)

Martin Michlmayr (1):
      [IA64] Fix section conflict of ia64_mlogbuf_finish

Simon Arlott (1):
      [IA64] spelling fixes: arch/ia64/

Tony Luck (2):
      [IA64] wire up {signal,timer,event}fd syscalls
      [IA64] s/scalibility/scalability/
