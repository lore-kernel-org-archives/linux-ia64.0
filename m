From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 03 Apr 2003 17:56:36 +0000
Subject: [Linux-ia64] [PATCH] 4/4 remove platform_pci_dma_address
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------7E9ADB67B19A95280B92F325"
Message-Id: <marc-linux-ia64-105590723705396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------7E9ADB67B19A95280B92F325
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Patch 4 removes platform_pci_dma_address.  Since the scatterlist
in 2.5 has a dma_address, seems like we can expect a certain usage
of it.  SGI folks may want to verify this doesn't break their DMA
engines.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------7E9ADB67B19A95280B92F325
Content-Type: text/plain; charset=us-ascii;
 name="patch-04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-04.diff"

diff -urN linux-2.5.64/arch/ia64/lib/swiotlb.c linux-work/arch/ia64/lib/swiotlb.c
--- linux-2.5.64/arch/ia64/lib/swiotlb.c	Tue Mar  4 20:29:32 2003
+++ linux-work/arch/ia64/lib/swiotlb.c	Tue Apr  1 09:19:53 2003
@@ -473,12 +473,6 @@
 			sync_single(hwdev, (void *) sg->dma_address, sg->dma_length, direction);
 }
 
-unsigned long
-swiotlb_dma_address (struct scatterlist *sg)
-{
-	return sg->dma_address;
-}
-
 /*
  * Return whether the given PCI device DMA address mask can be supported properly.  For
  * example, if your device can only drive the low 24-bits during PCI bus mastering, then
@@ -497,7 +491,6 @@
 EXPORT_SYMBOL(swiotlb_unmap_sg);
 EXPORT_SYMBOL(swiotlb_sync_single);
 EXPORT_SYMBOL(swiotlb_sync_sg);
-EXPORT_SYMBOL(swiotlb_dma_address);
 EXPORT_SYMBOL(swiotlb_alloc_consistent);
 EXPORT_SYMBOL(swiotlb_free_consistent);
 EXPORT_SYMBOL(swiotlb_pci_dma_supported);
diff -urN linux-2.5.64/include/asm-ia64/machvec.h linux-work/include/asm-ia64/machvec.h
--- linux-2.5.64/include/asm-ia64/machvec.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/machvec.h	Tue Apr  1 09:19:53 2003
@@ -43,7 +43,6 @@
 typedef void ia64_mv_pci_unmap_sg (struct pci_dev *, struct scatterlist *, int, int);
 typedef void ia64_mv_pci_dma_sync_single (struct pci_dev *, dma_addr_t, size_t, int);
 typedef void ia64_mv_pci_dma_sync_sg (struct pci_dev *, struct scatterlist *, int, int);
-typedef unsigned long ia64_mv_pci_dma_address (struct scatterlist *);
 typedef int ia64_mv_pci_dma_supported (struct pci_dev *, u64);
 
 /*
@@ -99,7 +98,6 @@
 #  define platform_pci_unmap_sg		ia64_mv.unmap_sg
 #  define platform_pci_dma_sync_single	ia64_mv.sync_single
 #  define platform_pci_dma_sync_sg	ia64_mv.sync_sg
-#  define platform_pci_dma_address	ia64_mv.dma_address
 #  define platform_pci_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -138,7 +136,6 @@
 	ia64_mv_pci_unmap_sg *unmap_sg;
 	ia64_mv_pci_dma_sync_single *sync_single;
 	ia64_mv_pci_dma_sync_sg *sync_sg;
-	ia64_mv_pci_dma_address *dma_address;
 	ia64_mv_pci_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -173,7 +170,6 @@
 	platform_pci_unmap_sg,			\
 	platform_pci_dma_sync_single,		\
 	platform_pci_dma_sync_sg,		\
-	platform_pci_dma_address,		\
 	platform_pci_dma_supported,		\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
@@ -206,7 +202,6 @@
 extern ia64_mv_pci_unmap_sg swiotlb_unmap_sg;
 extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
 extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
-extern ia64_mv_pci_dma_address swiotlb_dma_address;
 extern ia64_mv_pci_dma_supported swiotlb_pci_dma_supported;
 
 /*
@@ -266,9 +261,6 @@
 #endif
 #ifndef platform_pci_dma_sync_sg
 # define platform_pci_dma_sync_sg	swiotlb_sync_sg
-#endif
-#ifndef platform_pci_dma_address
-# define  platform_pci_dma_address	swiotlb_dma_address
 #endif
 #ifndef platform_pci_dma_supported
 # define  platform_pci_dma_supported	swiotlb_pci_dma_supported
diff -urN linux-2.5.64/include/asm-ia64/machvec_hpzx1.h linux-work/include/asm-ia64/machvec_hpzx1.h
--- linux-2.5.64/include/asm-ia64/machvec_hpzx1.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/machvec_hpzx1.h	Tue Apr  1 09:19:53 2003
@@ -8,7 +8,6 @@
 extern ia64_mv_pci_unmap_single sba_unmap_single;
 extern ia64_mv_pci_map_sg sba_map_sg;
 extern ia64_mv_pci_unmap_sg sba_unmap_sg;
-extern ia64_mv_pci_dma_address sba_dma_address;
 extern ia64_mv_pci_dma_supported sba_dma_supported;
 
 /*
@@ -29,7 +28,6 @@
 #define platform_pci_unmap_sg		sba_unmap_sg
 #define platform_pci_dma_sync_single	((ia64_mv_pci_dma_sync_single *) machvec_noop)
 #define platform_pci_dma_sync_sg	((ia64_mv_pci_dma_sync_sg *) machvec_noop)
-#define platform_pci_dma_address	sba_dma_address
 #define platform_pci_dma_supported	sba_dma_supported
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -urN linux-2.5.64/include/asm-ia64/machvec_sn1.h linux-work/include/asm-ia64/machvec_sn1.h
--- linux-2.5.64/include/asm-ia64/machvec_sn1.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/machvec_sn1.h	Tue Apr  1 09:19:53 2003
@@ -53,7 +53,6 @@
 extern ia64_mv_pci_unmap_sg		sn1_pci_unmap_sg;
 extern ia64_mv_pci_dma_sync_single	sn1_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn1_pci_dma_sync_sg;
-extern ia64_mv_pci_dma_address		sn1_dma_address;
 
 /*
  * This stuff has dual use!
@@ -84,6 +83,5 @@
 #define platform_pci_unmap_sg		sn1_pci_unmap_sg
 #define platform_pci_dma_sync_single	sn1_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn1_pci_dma_sync_sg
-#define platform_pci_dma_address	sn1_dma_address
 
 #endif /* _ASM_IA64_MACHVEC_SN1_h */
diff -urN linux-2.5.64/include/asm-ia64/machvec_sn2.h linux-work/include/asm-ia64/machvec_sn2.h
--- linux-2.5.64/include/asm-ia64/machvec_sn2.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/machvec_sn2.h	Tue Apr  1 09:19:53 2003
@@ -56,7 +56,6 @@
 extern ia64_mv_pci_unmap_sg		sn_pci_unmap_sg;
 extern ia64_mv_pci_dma_sync_single	sn_pci_dma_sync_single;
 extern ia64_mv_pci_dma_sync_sg		sn_pci_dma_sync_sg;
-extern ia64_mv_pci_dma_address		sn_dma_address;
 extern ia64_mv_pci_dma_supported	sn_pci_dma_supported;
 
 /*
@@ -91,7 +90,6 @@
 #define platform_pci_unmap_sg		sn_pci_unmap_sg
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
-#define platform_pci_dma_address	sn_dma_address
 #define platform_pci_dma_supported	sn_pci_dma_supported
 
 #endif /* _ASM_IA64_MACHVEC_SN2_H */

--------------7E9ADB67B19A95280B92F325--


