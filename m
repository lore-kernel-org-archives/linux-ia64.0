From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 22 Mar 2004 18:40:32 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <1079980831.2121.43.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-03-22 at 11:30, Bjorn Helgaas wrote:
> On Monday 22 March 2004 2:36 am, Andrew Morton wrote:
> > This adds the necessary stubs for ia64 and builds OK with my config, but it
> > needs a double-check.
> 
> I needed the following additional patch to build the generic kernel:

And we probably want sba_iommu to have it's own dma_error routine:

--- 1.39/arch/ia64/hp/common/sba_iommu.c	Mon Mar 15 07:51:33 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Mar 22 10:52:38 2004
@@ -1979,6 +1980,12 @@
 	return ((mask & 0xFFFFFFFFUL) = 0xFFFFFFFFUL);
 }
 
+int
+sba_dma_error (dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 __setup("nosbagart", nosbagart);
 
 static int __init
@@ -2004,6 +2011,7 @@
 
 __setup("sbapagesize=",sba_page_override);
 
+EXPORT_SYMBOL(sba_dma_error);
 EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);
 EXPORT_SYMBOL(sba_map_sg);
--- 1.8/include/asm-ia64/machvec_hpzx1.h	Sat Mar 13 23:54:58 2004
+++ edited/include/asm-ia64/machvec_hpzx1.h	Mon Mar 22 10:53:21 2004
@@ -9,6 +9,7 @@
 extern ia64_mv_dma_map_sg		sba_map_sg;
 extern ia64_mv_dma_unmap_sg		sba_unmap_sg;
 extern ia64_mv_dma_supported		sba_dma_supported;
+extern ia64_mv_dma_error		sba_dma_error;
 
 /*
  * This stuff has dual use!
@@ -31,5 +32,6 @@
 #define platform_dma_sync_single_for_device ((ia64_mv_dma_sync_single_for_device *) machvec_memory_fence)
 #define platform_dma_sync_sg_for_device	((ia64_mv_dma_sync_sg_for_device *) machvec_memory_fence)
 #define platform_dma_supported		sba_dma_supported
+#define platform_dma_error		sba_dma_error
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */




