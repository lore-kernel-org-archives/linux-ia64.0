From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 18 Aug 2008 23:46:31 +0000
Subject: [git pull] ia64 changes
Message-Id: <200808182346.m7INkVTO007983@agluck-lia64.sc.intel.com>
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

 arch/ia64/configs/sn2_defconfig | 1285 ---------------------------------------
 arch/ia64/ia32/ia32_entry.S     |    2 +-
 arch/ia64/ia32/ia32priv.h       |    7 -
 arch/ia64/ia32/sys_ia32.c       |  132 ----
 arch/ia64/kernel/smp.c          |    8 +-
 arch/ia64/pci/pci.c             |   21 +-
 6 files changed, 16 insertions(+), 1439 deletions(-)
 delete mode 100644 arch/ia64/configs/sn2_defconfig

Christoph Hellwig (1):
      [IA64] use generic compat_old_sys_readdir

Robin Holt (2):
      [IA64] Remove sn2_defconfig.
      [IA64] Shrink shadow_flush_counts to a short array to save 8k of per_cpu area.

Tony Luck (1):
      [IA64] pci_acpi_scan_root cleanup

