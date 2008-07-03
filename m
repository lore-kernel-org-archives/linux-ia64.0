From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 06:54:40 +0000
Subject: [PATCH] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <1215068105810-git-send-email-yamahata@valinux.co.jp>
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
 include/asm-ia64/meminit.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index 7245a57..6bc96ee 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
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
1.5.3

