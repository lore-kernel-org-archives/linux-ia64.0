From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 31 Mar 2003 21:51:04 +0000
Subject: [Linux-ia64] [PATCH] 2.4.20 sba_iommu bug fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------8635FABC11FEB051102C3E43"
Message-Id: <marc-linux-ia64-105590723705366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------8635FABC11FEB051102C3E43
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   This patch ensures that iopdir updates are visible on the bus
before we return a DMA mapping.  Without this there is a small
window where the chipset could fetch an invalid iodpir entry
from memory.  As Grant mentioned before, we've only seen this
problem exposed with multiple tulip NICs under load.  Bjorn,
please apply.  Working on something for 2.5... (more extensive
updates)  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------8635FABC11FEB051102C3E43
Content-Type: text/plain; charset=us-ascii;
 name="sba_iommu-pdir-coherency.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sba_iommu-pdir-coherency.diff"

--- linux/arch/ia64/hp/common/sba_iommu.c	11 Dec 2002 19:57:28 -0000	1.28
+++ linux/arch/ia64/hp/common/sba_iommu.c	31 Mar 2003 01:44:49 -0000
@@ -35,6 +35,7 @@
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
 #include <asm/page.h>		/* PAGE_OFFSET */
+#include <asm/system.h>		/* wmb() */
 
 
 #define PFX "IOC: "
@@ -816,6 +817,9 @@ sba_map_single(struct pci_dev *dev, void
 		size -= IOVP_SIZE;
 		pdir_start++;
 	}
+	/* force pdir update */
+	wmb();
+
 	/* form complete address */
 #ifdef ASSERT_PDIR_SANITY
 	sba_check_pdir(ioc,"Check after sba_map_single()");
@@ -1078,6 +1082,9 @@ sba_fill_pdir(
 		}
 		startsg++;
 	}
+	/* force pdir update */
+	wmb();
+
 #ifdef DEBUG_LARGE_SG_ENTRIES
 	dump_run_sg = 0;
 #endif

--------------8635FABC11FEB051102C3E43--


