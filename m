From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Feb 2009 21:02:42 +0000
Subject: [git pull] ia64 changes
Message-Id: <499dc8f263026d61@agluck-desktop.sc.intel.com>
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

 arch/ia64/Kconfig                    |    7 +-
 arch/ia64/configs/xen_domu_defconfig | 1601 ++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/sn/bte.h       |    2 +-
 arch/ia64/kernel/smpboot.c           |    5 +-
 arch/ia64/sn/kernel/bte.c            |    7 +-
 arch/ia64/xen/Kconfig                |    3 +-
 arch/ia64/xen/xen_pv_ops.c           |    4 +-
 7 files changed, 1617 insertions(+), 12 deletions(-)
 create mode 100644 arch/ia64/configs/xen_domu_defconfig

Alex Chiang (2):
      [IA64] Revert "prevent ia64 from invoking irq handlers on offline CPUs"
      [IA64] Remove redundant cpu_clear() in __cpu_disable path

Isaku Yamahata (1):
      [IA64] fixes configs and add default config for ia64 xen domU

Robin Holt (1):
      [IA64] bte_copy of BTE_MAX_XFER trips BUG_ON.

Tony Luck (2):
      [IA64] Build fix for __early_pfn_to_nid() undefined link error
      [IA64] xen_domu build fix

