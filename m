From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 25 Jan 2006 23:51:14 +0000
Subject: [PATCH]: Add PROM feature set for device flush list
Message-Id: <20060125235113.9721.46324.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Introduce PRF_DEVICE_FLUSH_LIST flag for older PROMs.

This patch depends on Dean Roe's previous patch,

http://marc.theaimsgroup.com/?l=linux-ia64&m3811317607416&w=2

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit 4ed422a973ed005a6dd4bd8f5297508ad30d4d73
tree 95dbca2ac7d9a63115e63917a6bc3902f98606d2
parent ff85044c690cfabb8079509d0f7cac093d5b436d
author Prarit Bhargava <prarit@sgi.com> Wed, 25 Jan 2006 14:45:49 -0500
committer Prarit Bhargava <prarit@sgi.com> Wed, 25 Jan 2006 14:45:49 -0500

 arch/ia64/sn/kernel/io_init.c         |   36 +++++++++++++++++----------------
 include/asm-ia64/sn/sn_feature_sets.h |    7 ++++--
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -10,6 +10,7 @@
 #include <linux/nodemask.h>
 #include <asm/sn/types.h>
 #include <asm/sn/addrs.h>
+#include <asm/sn/sn_feature_sets.h>
 #include <asm/sn/geo.h>
 #include <asm/sn/io.h>
 #include <asm/sn/pcibr_provider.h>
@@ -173,8 +174,8 @@ sn_pcidev_info_get(struct pci_dev *dev)
  */
 static u8 war_implemented = 0;
 
-static void sn_device_fixup_war(u64 nasid, u64 widget, int device,
-				struct sn_flush_device_common *common)
+static s64 sn_device_fixup_war(u64 nasid, u64 widget, int device,
+			       struct sn_flush_device_common *common)
 {
 	struct sn_flush_device_war *war_list;
 	struct sn_flush_device_war *dev_entry;
@@ -198,8 +199,9 @@ static void sn_device_fixup_war(u64 nasi
 
 	dev_entry = war_list + device;
 	memcpy(common,dev_entry, sizeof(*common));
-
 	kfree(war_list);
+
+	return isrv.status;
 }
 
 /*
@@ -279,23 +281,21 @@ static void sn_fixup_ionodes(void)
 				memset(dev_entry->common, 0x0, sizeof(struct
 					     	       sn_flush_device_common));
 
-				status = sal_get_device_dmaflush_list(nasid,
-									widget,
-								       	device,
+				if (sn_prom_feature_available(
+						       PRF_DEVICE_FLUSH_LIST))
+					status = sal_get_device_dmaflush_list(
+									  nasid,
+									 widget,
+								       	 device,
 						      (u64)(dev_entry->common));
-				if (status) {
-					if (sn_sal_rev() < 0x0450) {
-						/* shortlived WAR for older
-						 * PROM images
-						 */
-						sn_device_fixup_war(nasid,
-								    widget,
-								    device,
+				else
+					status = sn_device_fixup_war(nasid,
+								     widget,
+							    	     device,
 							     dev_entry->common);
-					}
-					else
-						BUG();
-				}
+				if (status != SALRET_OK)
+					panic("SAL call failed: %s\n",
+					      ia64_sal_strerror(status));
 
 				spin_lock_init(&dev_entry->sfdl_flush_lock);
 			}
diff --git a/include/asm-ia64/sn/sn_feature_sets.h b/include/asm-ia64/sn/sn_feature_sets.h
--- a/include/asm-ia64/sn/sn_feature_sets.h
+++ b/include/asm-ia64/sn/sn_feature_sets.h
@@ -30,7 +30,8 @@ extern int sn_prom_feature_available(int
  * 		if (sn_prom_feature_available(PRF_XXX))
  * 			...
  */
-#define PRF_PAL_CACHE_FLUSH_SAFE		0
+#define PRF_PAL_CACHE_FLUSH_SAFE	0
+#define PRF_DEVICE_FLUSH_LIST		1
 
 
 
@@ -47,7 +48,7 @@ extern int sn_prom_feature_available(int
  *
  * By default, features are disabled unless explicitly enabled.
  */
-#define  OSF_MCA_SLV_TO_OS_INIT_SLV		0
-#define  OSF_FEAT_LOG_SBES			1
+#define  OSF_MCA_SLV_TO_OS_INIT_SLV	0
+#define  OSF_FEAT_LOG_SBES		1
 
 #endif /* _ASM_IA64_SN_FEATURE_SETS_H */
