From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jan 2006 21:39:11 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200601312139.k0VLdBcs008928@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
In-Reply-To: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
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

 MAINTAINERS                           |    4 +--
 arch/ia64/kernel/mca_asm.S            |    2 -
 arch/ia64/kernel/unaligned.c          |    3 +-
 arch/ia64/sn/kernel/io_init.c         |   36 +++++++++++++++++-----------------
 arch/ia64/sn/kernel/xpc_channel.c     |    6 ++---
 arch/ia64/sn/pci/pci_dma.c            |    4 +--
 include/asm-ia64/sn/sn_feature_sets.h |   16 ++++++---------
 7 files changed, 35 insertions(+), 36 deletions(-)

Dean Roe:
      [IA64-SGI] add sn_feature_sets bit

Greg Edwards:
      [IA64] sn2 maintainer update (Jes Sorensen)

Jack Steiner:
      [IA64] Scaling fix for simultaneous unaligned accesses

Jes Sorensen:
      [IA64-SGI] XPC remove unnecessary GFP_DMA flag

Keith Owens:
      [IA64] Set the correct default OS status in the MCA handler

Prarit Bhargava:
      [IA64-SGI] Add PROM feature set for device flush list

Takashi Iwai:
      [IA64-SGI] sn_dma_alloc_coherent should use gfp flags

diff-tree 61d67f2e07d96d20d86135792ca591c491939c27 (from 139366a093d1ce2749b1b4247947ceb9b78caa2a)
Author: Prarit Bhargava <prarit@sgi.com>
Date:   Wed Jan 25 18:51:14 2006 -0500

    [IA64-SGI] Add PROM feature set for device flush list
    
    Introduce PRF_DEVICE_FLUSH_LIST flag for older PROMs.
    
    Signed-off-by: Prarit Bhargava <prarit@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 00700f7..a4c7815 100644
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
index f63f144..9ca642c 100644
--- a/include/asm-ia64/sn/sn_feature_sets.h
+++ b/include/asm-ia64/sn/sn_feature_sets.h
@@ -31,7 +31,8 @@ extern int sn_prom_feature_available(int
  * 			...
  */
 
-#define PRF_PAL_CACHE_FLUSH_SAFE		0
+#define PRF_PAL_CACHE_FLUSH_SAFE	0
+#define PRF_DEVICE_FLUSH_LIST		1
 
 
 
@@ -48,7 +49,7 @@ extern int sn_prom_feature_available(int
  *
  * By default, features are disabled unless explicitly enabled.
  */
-#define  OSF_MCA_SLV_TO_OS_INIT_SLV		0
-#define  OSF_FEAT_LOG_SBES			1
+#define  OSF_MCA_SLV_TO_OS_INIT_SLV	0
+#define  OSF_FEAT_LOG_SBES		1
 
 #endif /* _ASM_IA64_SN_FEATURE_SETS_H */

diff-tree 139366a093d1ce2749b1b4247947ceb9b78caa2a (from e5ee7dda96476e09ee63af464ea17ddad1dc489d)
Author: Jes Sorensen <jes@sgi.com>
Date:   Tue Jan 24 04:23:16 2006 -0500

    [IA64-SGI] XPC remove unnecessary GFP_DMA flag
    
    Remove the GFP_DMA flag from XPC kmalloc() calls.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Acked-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index 8d950c7..36e5437 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -447,7 +447,7 @@ xpc_allocate_local_msgqueue(struct xpc_c
 
 		nbytes = nentries * ch->msg_size;
 		ch->local_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
-						(GFP_KERNEL | GFP_DMA),
+						GFP_KERNEL,
 						&ch->local_msgqueue_base);
 		if (ch->local_msgqueue = NULL) {
 			continue;
@@ -455,7 +455,7 @@ xpc_allocate_local_msgqueue(struct xpc_c
 		memset(ch->local_msgqueue, 0, nbytes);
 
 		nbytes = nentries * sizeof(struct xpc_notify);
-		ch->notify_queue = kmalloc(nbytes, (GFP_KERNEL | GFP_DMA));
+		ch->notify_queue = kmalloc(nbytes, GFP_KERNEL);
 		if (ch->notify_queue = NULL) {
 			kfree(ch->local_msgqueue_base);
 			ch->local_msgqueue = NULL;
@@ -502,7 +502,7 @@ xpc_allocate_remote_msgqueue(struct xpc_
 
 		nbytes = nentries * ch->msg_size;
 		ch->remote_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
-						(GFP_KERNEL | GFP_DMA),
+						GFP_KERNEL,
 						&ch->remote_msgqueue_base);
 		if (ch->remote_msgqueue = NULL) {
 			continue;

diff-tree e5ee7dda96476e09ee63af464ea17ddad1dc489d (from fd8b206d1621ad526e7b00dc26322f546b2a57fb)
Author: Greg Edwards <edwardsg@sgi.com>
Date:   Wed Jan 18 10:21:59 2006 -0600

    [IA64] sn2 maintainer update (Jes Sorensen)
    
    We lured Jes to the dark side, and he's going to take over as the sn2
    maintainer.  His experience and thoroughness will serve him well here.
    
    Signed-off-by: Greg Edwards <edwardsg@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 3f8a90a..a37a2b3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1176,8 +1176,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
 S:	Maintained
 
 SN-IA64 (Itanium) SUB-PLATFORM
-P:	Greg Edwards
-M:	edwardsg@sgi.com
+P:	Jes Sorensen
+M:	jes@sgi.com
 L:	linux-altix@sgi.com
 L:	linux-ia64@vger.kernel.org
 W:	http://www.sgi.com/altix

diff-tree fd8b206d1621ad526e7b00dc26322f546b2a57fb (from 79c83bd15af3b06079a9205db9c64c92ca1bd868)
Author: Dean Roe <roe@sgi.com>
Date:   Tue Jan 24 14:49:43 2006 -0800

    [IA64-SGI] add sn_feature_sets bit
    
    SGI's prom has added a new feature which avoids an Altix-specific
    MCA that can occur with excessive use of ia64_pal_cache_flush.  This
    patch adds the #define to the sn_feature_sets.h to reflect that bit
    is taken.
    
    Signed-off-by: Dean Roe <roe@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/sn_feature_sets.h b/include/asm-ia64/sn/sn_feature_sets.h
index e68a808..f63f144 100644
--- a/include/asm-ia64/sn/sn_feature_sets.h
+++ b/include/asm-ia64/sn/sn_feature_sets.h
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2005-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -27,14 +27,11 @@ extern int sn_prom_feature_available(int
  * "false" for new features.
  *
  * Use:
- * 		if (sn_prom_feature_available(PRF_FEATURE_XXX))
+ * 		if (sn_prom_feature_available(PRF_XXX))
  * 			...
  */
 
-/*
- * Example: feature XXX
- */
-#define PRF_FEATURE_XXX		0
+#define PRF_PAL_CACHE_FLUSH_SAFE		0
 
 
 

diff-tree 79c83bd15af3b06079a9205db9c64c92ca1bd868 (from dc64161343015162a3fabfcd20b9b84409af67d5)
Author: Jack Steiner <steiner@sgi.com>
Date:   Tue Jan 24 16:32:11 2006 -0600

    [IA64] Scaling fix for simultaneous unaligned accesses
    
    Eliminate a hot shared cacheline that occurs if multiple cpus are
    taking unaligned exceptions.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 43b45b6..f9e0ae9 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -1283,8 +1283,9 @@ within_logging_rate_limit (void)
 
 	if (jiffies - last_time > 5*HZ)
 		count = 0;
-	if (++count < 5) {
+	if (count < 5) {
 		last_time = jiffies;
+		count++;
 		return 1;
 	}
 	return 0;

diff-tree dc64161343015162a3fabfcd20b9b84409af67d5 (from 2a792058c3aaf5fb806e09a456e25b9f4f748dd1)
Author: Takashi Iwai <tiwai@suse.de>
Date:   Tue Jan 24 14:30:56 2006 -0800

    [IA64-SGI] sn_dma_alloc_coherent should use gfp flags
    
    Takashi helped us track down a bad page state bug we thought was coming
    from alsa.  It turns out we weren't paying attention to the gfp flags
    that were passed in to sn_dma_alloc_coherent().
    
    From: Takashi Iwai <tiwai@suse.de>
    Signed-off-by: Greg Edwards <edwardsg@sgi.com>
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Jes Sorensen <jes@sgi.com>

diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 9bf9f23..5a36292 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -90,14 +90,14 @@ void *sn_dma_alloc_coherent(struct devic
 	 */
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
-		struct page *p = alloc_pages_node(node, GFP_ATOMIC, get_order(size));
+		struct page *p = alloc_pages_node(node, flags, get_order(size));
 
 		if (likely(p))
 			cpuaddr = page_address(p);
 		else
 			return NULL;
 	} else
-		cpuaddr = (void *)__get_free_pages(GFP_ATOMIC, get_order(size));
+		cpuaddr = (void *)__get_free_pages(flags, get_order(size));
 
 	if (unlikely(!cpuaddr))
 		return NULL;

diff-tree 2a792058c3aaf5fb806e09a456e25b9f4f748dd1 (from 3ee68c4af3fd7228c1be63254b9f884614f9ebb2)
Author: Keith Owens <kaos@sgi.com>
Date:   Tue Jan 24 12:31:26 2006 +1100

    [IA64] Set the correct default OS status in the MCA handler
    
    sos->os_status is set to a default value of IA64_MCA_COLD_BOOT for an
    MCA, but then is incorrectly overwritten with IA64_MCA_SAME_CONTEXT (0).
    This makes SAL think that all MCAs have been recovered.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 403a80a..60a464b 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -512,7 +512,7 @@ ia64_state_save:
 	st8 [temp1]=r12		// os_status, default is cold boot
 	mov r6=IA64_MCA_SAME_CONTEXT
 	;;
-	st8 [temp1]=r6		// context, default is same context
+	st8 [temp2]=r6		// context, default is same context
 
 	// Save the pt_regs data that is not in minstate.  The previous code
 	// left regs at sos.
