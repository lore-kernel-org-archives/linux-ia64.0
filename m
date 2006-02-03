From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Feb 2006 00:03:07 +0000
Subject: patches added to release/test trees
Message-Id: <200602030003.k130374M032634@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches have been added to the release tree:

Bjorn Helgaas:
      [IA64] avoid broken SAL_CACHE_FLUSH implementations

Chen, Kenneth W:
      [IA64] remove staled comments in asm/system.h

Jack Steiner:
      [IA64-SGI] Update TLB flushing code for SN platform (pulled from test)

Jes Sorensen:
      drivers/sn/ must be entered for CONFIG_SGI_IOC3 (pulled from test)
      [IA64-SGI] sn2 housekeeping
      [IA64-SGI] include/asm-ia64/sn/intr.h more sn2 housekeeping

Kyle McMartin:
      [IA64] Remove stale comment from ia64/Kconfig

Mark Maule:
      [IA64-SGI] fix smp_affinity redirection when using CONFIG_PCI_MSI
      [IA64-SGI] disable msi for all altix pci devices

Robin Holt:
      [IA64-SGI] Fix XPC code which sleeps with spin_lock_irqsave().

