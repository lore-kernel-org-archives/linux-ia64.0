From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 14 Oct 2008 05:51:21 +0000
Subject: [PATCH 06/32] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <1223963507-28056-7-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
as start info.

Cc: Robin Holt <holt@sgi.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/meminit.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/meminit.h
index 7245a57..6bc96ee 100644
--- a/arch/ia64/include/asm/meminit.h
+++ b/arch/ia64/include/asm/meminit.h
@@ -18,10 +18,11 @@
  * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  * 	- ELF core header
+ *	- xen start info if CONFIG_XEN
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 8
+#define IA64_MAX_RSVD_REGIONS 9
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
-- 
1.6.0.2

