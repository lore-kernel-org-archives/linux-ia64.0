From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:19 +0000
Subject: [PATCH 03/28] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <12036570474112-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
as start info.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/meminit.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index f93308f..7c12c08 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -18,10 +18,17 @@
  * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  * 	- ELF core header
+ * ifdef CONFIG_XEN
+ *	- xen start info
+ * endif
  *
  * More could be added if necessary
  */
+#ifdef CONFIG_XEN
 #define IA64_MAX_RSVD_REGIONS 8
+#else
+#define IA64_MAX_RSVD_REGIONS 9
+#endif
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
-- 
1.5.3

