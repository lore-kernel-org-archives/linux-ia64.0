From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Apr 2004 18:38:29 +0000
Subject: heads up: 2.6.5 triggers Nvidia binary-only driver bug
Message-Id: <16509.34085.831565.155412@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It turns out the attached patch triggers a latent bug in the Nvidia
binary-only driver.  The quick workaround is to comment out the line
"MAX_DMA_ADDRESS = ~0UL" in sba_setup().  The problem appears to be
that the Nvidia driver is incorrectly assuming that allocating with
GFP_DMA will give addresses below 4GB.

I believe it's possible to fix this properly in the Nvidia driver
(without touching the binary-only portion of the driver, I mean).  If
someone is eager to investigate, please let me know so I can take it
off of my list of things to worry about.

Thanks,

	--david

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/04/05 14:22:54-07:00 alex.williamson@hp.com 
#   [PATCH] ia64: setup max dma addr earlier on hp boxes
#   
#   sba_iommu was setting up MAX_DMA_ADDRESS way too late to do any
#   good.  This patch makes it get setup via platform_setup, so it's ready
#   for paging_init().  All pages should show up in zone DMA now.  Against
#   latest 2.6.
# 
# include/asm-ia64/machvec_hpzx1.h
#   2004/04/05 04:07:18-07:00 alex.williamson@hp.com +2 -1
#   ia64: setup max dma addr earlier on hp boxes
# 
# arch/ia64/hp/common/sba_iommu.c
#   2004/04/05 04:14:20-07:00 alex.williamson@hp.com +12 -1
#   ia64: setup max dma addr earlier on hp boxes
# 
diff -Nru a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c	Wed Apr 14 11:34:56 2004
+++ b/arch/ia64/hp/common/sba_iommu.c	Wed Apr 14 11:34:56 2004
@@ -1732,7 +1732,6 @@
 
 	if ((long) ~iovp_mask > (long) ia64_max_iommu_merge_mask)
 		ia64_max_iommu_merge_mask = ~iovp_mask;
-	MAX_DMA_ADDRESS = ~0UL;
 
 	printk(KERN_INFO PFX
 		"%s %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
@@ -1965,6 +1964,18 @@
 }
 
 subsys_initcall(sba_init); /* must be initialized after ACPI etc., but before any drivers... */
+
+extern void dig_setup(char**);
+/*
+ * MAX_DMA_ADDRESS needs to be setup prior to paging_init to do any good,
+ * so we use the platform_setup hook to fix it up.
+ */
+void __init
+sba_setup(char **cmdline_p)
+{
+	MAX_DMA_ADDRESS = ~0UL;
+	dig_setup(cmdline_p);
+}
 
 static int __init
 nosbagart(char *str)
diff -Nru a/include/asm-ia64/machvec_hpzx1.h b/include/asm-ia64/machvec_hpzx1.h
--- a/include/asm-ia64/machvec_hpzx1.h	Wed Apr 14 11:34:56 2004
+++ b/include/asm-ia64/machvec_hpzx1.h	Wed Apr 14 11:34:56 2004
@@ -2,6 +2,7 @@
 #define _ASM_IA64_MACHVEC_HPZX1_h
 
 extern ia64_mv_setup_t dig_setup;
+extern ia64_mv_setup_t			sba_setup;
 extern ia64_mv_dma_alloc_coherent	sba_alloc_coherent;
 extern ia64_mv_dma_free_coherent	sba_free_coherent;
 extern ia64_mv_dma_map_single		sba_map_single;
@@ -19,7 +20,7 @@
  * the macros are used directly.
  */
 #define platform_name			"hpzx1"
-#define platform_setup			dig_setup
+#define platform_setup			sba_setup
 #define platform_dma_init		machvec_noop
 #define platform_dma_alloc_coherent	sba_alloc_coherent
 #define platform_dma_free_coherent	sba_free_coherent
