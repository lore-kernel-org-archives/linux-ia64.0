From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 24 May 2002 05:26:34 +0000
Subject: [Linux-ia64] [PATCH] compilation fixes for i460 with 2.5.1[5-7] kernels
Message-Id: <marc-linux-ia64-105590701905594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since 2.5.15, a few interfaces are no longer exported from filemap.c
--- which means the code for getting and releasing locked pages in
files .../agp/agpgart_be.c, .../drm/radeon.c, and .../drm/r128_cce.c
has to be changed.

Question:  Is it *really* necessary to lock these pages?  As they're
grabbed from the freepage list, they're not backed by a file, so noone
else will ever try to get the page.  (Or have I misunderstood
completely what's going on here?)  So what's it locking against? 

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.540   -> 1.541  
#	drivers/char/agp/agpgart_be.c	1.30    -> 1.31   
#	drivers/char/drm/r128_cce.c	1.6     -> 1.7    
#	drivers/char/drm/radeon_cp.c	1.7     -> 1.8    
#	drivers/char/drm/r128_drv.h	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/05/24	peterc@lemon.gelato.unsw.edu.au	1.541
# Replace explicit bit twiddling in struct page with calls to the correct interface functions
# in IA64-specific parts of the DRM/AGP stuff.
# 
# wake_up_page() is no longer available (as of 2.5.15)
# 
# Clean up r128_cce.c
# --------------------------------------------
#
diff -Nru a/drivers/char/agp/agpgart_be.c b/drivers/char/agp/agpgart_be.c
--- a/drivers/char/agp/agpgart_be.c	Fri May 24 15:31:15 2002
+++ b/drivers/char/agp/agpgart_be.c	Fri May 24 15:31:15 2002
@@ -1739,8 +1739,8 @@
 	bp_end = bp + ((PAGE_SIZE * (1 << (intel_i460_pageshift - PAGE_SHIFT))) - 1);
 
 	for (page = virt_to_page(bp); page <= virt_to_page(bp_end); page++) {
-		atomic_inc(&page->count);
-		set_bit(PG_locked, &page->flags);
+		get_page(page);
+		lock_page(page);
 		atomic_inc(&agp_bridge.current_memory_agp);
 	}
 	return bp;
@@ -1758,9 +1758,8 @@
 	i460_pg_detail[pg_num] = NULL;
 
 	for (page = virt_to_page(bp); page < virt_to_page(bp_end); page++) {
-		atomic_dec(&page->count);
-		clear_bit(PG_locked, &page->flags);
-		wake_up_page(page);
+		put_page(page);
+		unlock_page(page);
 		atomic_dec(&agp_bridge.current_memory_agp);
 	}
 
diff -Nru a/drivers/char/drm/r128_cce.c b/drivers/char/drm/r128_cce.c
--- a/drivers/char/drm/r128_cce.c	Fri May 24 15:31:15 2002
+++ b/drivers/char/drm/r128_cce.c	Fri May 24 15:31:15 2002
@@ -36,6 +36,11 @@
 #include <linux/interrupt.h>	/* For task queue support */
 #include <linux/delay.h>
 
+
+#ifdef CONFIG_AGP_I460
+# include <linux/pagemap.h> /* for unlock_page */
+#endif
+
 #define R128_FIFO_DEBUG		0
 
 
@@ -229,7 +234,7 @@
 		 * a better solution.
 		 */
  		if ( GET_RING_HEAD( &dev_priv->ring ) = dev_priv->ring.tail
-		     || ( dev->agp->agp_info.chipset = INTEL_460GX
+		     || ( dev_priv->cce_is_i460
 			  && ( dev_priv->ring.tail - GET_RING_HEAD( &dev_priv->ring ) ) = 2 ) )
 		{
 #endif
@@ -369,8 +374,10 @@
 			unsigned long alt_rh_off;
 
 			alt_rh_off = __get_free_page(GFP_KERNEL | GFP_DMA);
-			atomic_inc(&virt_to_page(alt_rh_off)->count);
-			set_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
+			if (alt_rh_off = 0UL)
+				BUG();
+			get_page(virt_to_page(alt_rh_off));
+			SetPageLocked(virt_to_page(alt_rh_off));
 
 			dev_priv->ring.head = (__volatile__ u32 *) alt_rh_off;
 			SET_RING_HEAD( &dev_priv->ring, 0 );
@@ -431,6 +438,10 @@
 	memset( dev_priv, 0, sizeof(drm_r128_private_t) );
 
 	dev_priv->is_pci = init->is_pci;
+#ifdef CONFIG_AGP_I460
+	dev_priv->cce_is_i460 = dev->agp->agp_info.chipset = INTEL_460GX;
+#endif
+
 
 	if ( dev_priv->is_pci && !dev->sg ) {
 		DRM_ERROR( "PCI GART memory not allocated!\n" );
@@ -687,10 +698,12 @@
 			unsigned long alt_rh_off  				(unsigned long) dev_priv->ring.head;
 
-			atomic_dec(&virt_to_page(alt_rh_off)->count);
-			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
-			wake_up(&virt_to_page(alt_rh_off)->wait);
-			free_page(alt_rh_off);
+			if (alt_rh_off) {
+				struct page *p = virt_to_page(alt_rh_off);
+				put_page(p);
+				unlock_page(p);
+				__free_page(p);
+			}
 		}
 #endif
 	
diff -Nru a/drivers/char/drm/r128_drv.h b/drivers/char/drm/r128_drv.h
--- a/drivers/char/drm/r128_drv.h	Fri May 24 15:31:15 2002
+++ b/drivers/char/drm/r128_drv.h	Fri May 24 15:31:15 2002
@@ -65,7 +65,9 @@
 	int cce_mode;
 	int cce_fifo_size;
 	int cce_running;
-
+#ifdef CONFIG_AGP_I460
+	int is_i460;
+#endif
    	drm_r128_freelist_t *head;
    	drm_r128_freelist_t *tail;
 
diff -Nru a/drivers/char/drm/radeon_cp.c b/drivers/char/drm/radeon_cp.c
--- a/drivers/char/drm/radeon_cp.c	Fri May 24 15:31:15 2002
+++ b/drivers/char/drm/radeon_cp.c	Fri May 24 15:31:15 2002
@@ -36,6 +36,10 @@
 #include <linux/interrupt.h>	/* For task queue support */
 #include <linux/delay.h>
 
+#ifdef CONFIG_AGP_I460
+# include <linux/pagemap.h> /* for unlock_page */
+#endif
+
 #define RADEON_FIFO_DEBUG	0
 
 #if defined(__alpha__)
@@ -624,8 +628,10 @@
 			unsigned long alt_rh_off;
 
 			alt_rh_off = __get_free_page(GFP_KERNEL | GFP_DMA);
-			atomic_inc(&virt_to_page(alt_rh_off)->count);
-			set_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
+			if (alt_rh_off = 0UL)
+				BUG();
+			get_page(virt_to_page(alt_rh_off));
+			SetPageLocked(virt_to_page(alt_rh_off));
 
 			dev_priv->ring.head = (__volatile__ u32 *) alt_rh_off;
 			*dev_priv->ring.head = cur_read_ptr;
@@ -650,7 +656,7 @@
 #else
 		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
 			     entry->busaddr[page_ofs]);
-		DRM_DEBUG( "ring rptr: offset=0x%08x handle=0x%08lx\n",
+		DRM_DEBUG( "ring rptr: offset=%08lx handle=0x%08lx\n",
 			   entry->busaddr[page_ofs],
 			   entry->handle + tmp_ofs );
 #endif
@@ -1027,11 +1033,12 @@
 		 */
 		if( !dev_priv->is_pci && dev->agp->agp_info.chipset = INTEL_460GX ) {
 			unsigned long alt_rh_off = (unsigned long) dev_priv->ring.head;
-
-			atomic_dec(&virt_to_page(alt_rh_off)->count);
-			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
-			wake_up(&virt_to_page(alt_rh_off)->wait);
-			free_page(alt_rh_off);
+			if (alt_rh_off) {
+				struct page *p = virt_to_page(alt_rh_off);
+				put_page(p);
+				unlock_page(p);
+				__free_page(p);
+			}
 		}
 #endif
 		DRM(free)( dev->dev_private, sizeof(drm_radeon_private_t), DRM_MEM_DRIVER );



