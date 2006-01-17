From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jan 2006 04:30:23 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200601170430.k0H4UNP0019665@agluck-lia64.sc.intel.com>
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

This will update the files shown below.  Looks big in the diffstat, but >90%
of the changes come from Prarit's cleanup of the SGI code to swapout all the
uint64_t for u64 etc.

Thanks!

-Tony

 arch/ia64/kernel/perfmon.c                 |    2 
 arch/ia64/kernel/perfmon_montecito.h       |  269 +++++
 arch/ia64/mm/init.c                        |   36 
 arch/ia64/pci/pci.c                        |   19 
 arch/ia64/sn/include/xtalk/hubdev.h        |   10 
 arch/ia64/sn/include/xtalk/xbow.h          |  198 +--
 arch/ia64/sn/include/xtalk/xwidgetdev.h    |   46 
 arch/ia64/sn/kernel/io_init.c              |   10 
 arch/ia64/sn/kernel/irq.c                  |   10 
 arch/ia64/sn/kernel/tiocx.c                |   18 
 arch/ia64/sn/pci/pcibr/pcibr_ate.c         |   16 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c         |   44 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c    |   12 
 arch/ia64/sn/pci/pcibr/pcibr_reg.c         |   28 
 arch/ia64/sn/pci/tioca_provider.c          |   36 
 arch/ia64/sn/pci/tioce_provider.c          |   68 -
 include/asm-ia64/pal.h                     |    2 
 include/asm-ia64/processor.h               |    4 
 include/asm-ia64/sn/intr.h                 |    2 
 include/asm-ia64/sn/pcibr_provider.h       |   48 
 include/asm-ia64/sn/pcibus_provider_defs.h |   14 
 include/asm-ia64/sn/pcidev.h               |    4 
 include/asm-ia64/sn/pic.h                  |  204 +--
 include/asm-ia64/sn/shubio.h               | 1552 ++++++++++++++---------------
 include/asm-ia64/sn/sn_sal.h               |   12 
 include/asm-ia64/sn/tioca.h                |   78 -
 include/asm-ia64/sn/tioca_provider.h       |   56 -
 include/asm-ia64/sn/tioce.h                |  652 ++++++------
 include/asm-ia64/sn/tioce_provider.h       |   30 
 include/asm-ia64/sn/tiocp.h                |  254 ++--
 include/asm-ia64/sn/tiocx.h                |   14 
 31 files changed, 2037 insertions(+), 1711 deletions(-)

Kenji Kaneshige:
      [IA64] Stop multiple pci_claim_resource() call for the same resource

Prarit Bhargava:
      [IA64] Cleanup of arch/ia64/sn and include/asm-ia64/sn

Stephane Eranian:
      [IA64] Perfmon for Montecito

Xu, Anthony:
      [IA64] pal cache flush patch

Yasunori Goto:
      [IA64] Simple memory hot-add for ia64.

