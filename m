From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Wed, 15 Aug 2001 05:08:40 +0000
Subject: [Linux-ia64] agpgart/drm Update
Message-Id: <marc-linux-ia64-105590698805081@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was able to cook up some patches to get agpgart/drm/dri working within
the framework introduced with the release of 2.4.8.  These patches use
the drm + drm-4.0 idea that Kieth mentioned on this list.  I sent these
patches along to David offlist since they're rather large.

Anyway, I thought I'd give a general update on what's known to work.
I've tested the following combinations:

      Video Card           DRM              XFree86
      ----------           ---              -------

      ATI Radeon           New              4.1.0+
      ATI Rage128          New              4.1.0+
      ATI Rage128          Old              4.0.2+
      Matrox G450          New              4.1.0+

Matrox G400 should work with the old DRM and XFree86 4.0.2+ and the ATI
Radeon should work with the old DRM and XFree86 4.0.3+, however I didn't
get a chance to test these combos.

The + after XFree86 version denotes the fact that small patches need to
be applied to X itself for the whole package to work.  These are needed
to combat 'a page is 4KB' assumptions.  A patch for older XFree86
sources (actually against a 010321 snapshot) can be found at

   https://external-lists.valinux.com/archives/linux-ia64/2001-March/001326.html

A patch against the current DRI CVS, which should apply pretty well to any
recent copy of XFree86, is appended.

If anyone's real anxious to run 4.1.0 style drm on ia64, let me know and
I'll send along the patches directly.  Once the patches get integrated into
David's tree, I'd love to hear bug reports or success stories from
anyone who tries it out.  It works here, but that's just not completely
satisfying :-)

Chris


--- xc.old/programs/Xserver/hw/xfree86/drivers/ati/radeon_dri.c	Thu Jun 14 15:23:41 2001
+++ xc/programs/Xserver/hw/xfree86/drivers/ati/radeon_dri.c	Tue Aug 14 19:06:03 2001
@@ -58,13 +58,7 @@
 # undef PCIGART_ENABLED
 #endif
 
-/* ?? HACK - for now, put this here... */
-/* ?? Alpha - this may need to be a variable to handle UP1x00 vs TITAN */
-#if defined(__alpha__)
-# define DRM_PAGE_SIZE 8192
-#else
-# define DRM_PAGE_SIZE 4096
-#endif
+static size_t radeon_drm_page_size;
 
 /* Initialize the visual configs that are supported by the hardware.
    These are combined with the visual configs that the indirect
@@ -769,11 +763,11 @@
 
 				/* Initialize the CP ring buffer data */
     info->ringStart       = info->agpOffset;
-    info->ringMapSize     = info->ringSize*1024*1024 + DRM_PAGE_SIZE;
+    info->ringMapSize     = info->ringSize*1024*1024 + radeon_drm_page_size;
     info->ringSizeLog2QW  = RADEONMinBits(info->ringSize*1024*1024/8)-1;
 
     info->ringReadOffset  = info->ringStart + info->ringMapSize;
-    info->ringReadMapSize = DRM_PAGE_SIZE;
+    info->ringReadMapSize = radeon_drm_page_size;
 
 				/* Reserve space for vertex/indirect buffers */
     info->bufStart        = info->ringReadOffset + info->ringReadMapSize;
@@ -898,11 +892,11 @@
 
 				/* Initialize the CCE ring buffer data */
     info->ringStart       = info->agpOffset;
-    info->ringMapSize     = info->ringSize*1024*1024 + DRM_PAGE_SIZE;
+    info->ringMapSize     = info->ringSize*1024*1024 + radeon_drm_page_size;
     info->ringSizeLog2QW  = RADEONMinBits(info->ringSize*1024*1024/8)-1;
 
     info->ringReadOffset  = info->ringStart + info->ringMapSize;
-    info->ringReadMapSize = DRM_PAGE_SIZE;
+    info->ringReadMapSize = radeon_drm_page_size;
 
 				/* Reserve space for vertex/indirect buffers */
     info->bufStart        = info->ringReadOffset + info->ringReadMapSize;
@@ -1331,6 +1325,8 @@
     case 32:
 	break;
     }
+
+    radeon_drm_page_size = getpagesize();
 
     /* Create the DRI data structure, and fill it in before calling the
        DRIScreenInit(). */
--- xc.old/programs/Xserver/hw/xfree86/drivers/ati/r128_dri.c	Tue Aug  7 11:15:08 2001
+++ xc/programs/Xserver/hw/xfree86/drivers/ati/r128_dri.c	Tue Aug 14 19:02:35 2001
@@ -54,13 +54,7 @@
 #include "GL/glxtokens.h"
 #include "sarea.h"
 
-/* ?? HACK - for now, put this here... */
-/* ?? Alpha - this may need to be a variable to handle UP1x00 vs TITAN */
-#if defined(__alpha__)
-# define DRM_PAGE_SIZE 8192
-#else
-# define DRM_PAGE_SIZE 4096
-#endif
+static size_t r128_drm_page_size;
 
 /* Initialize the visual configs that are supported by the hardware.
    These are combined with the visual configs that the indirect
@@ -468,11 +462,11 @@
 
 				/* Initialize the CCE ring buffer data */
     info->ringStart       = info->agpOffset;
-    info->ringMapSize     = info->ringSize*1024*1024 + DRM_PAGE_SIZE;
+    info->ringMapSize     = info->ringSize*1024*1024 + r128_drm_page_size;
     info->ringSizeLog2QW  = R128MinBits(info->ringSize*1024*1024/8) - 1;
 
     info->ringReadOffset  = info->ringStart + info->ringMapSize;
-    info->ringReadMapSize = DRM_PAGE_SIZE;
+    info->ringReadMapSize = r128_drm_page_size;
 
 				/* Reserve space for vertex/indirect buffers */
     info->bufStart        = info->ringReadOffset + info->ringReadMapSize;
@@ -622,11 +616,11 @@
 
 				/* Initialize the CCE ring buffer data */
     info->ringStart       = info->agpOffset;
-    info->ringMapSize     = info->ringSize*1024*1024 + DRM_PAGE_SIZE;
+    info->ringMapSize     = info->ringSize*1024*1024 + r128_drm_page_size;
     info->ringSizeLog2QW  = R128MinBits(info->ringSize*1024*1024/8) - 1;
 
     info->ringReadOffset  = info->ringStart + info->ringMapSize;
-    info->ringReadMapSize = DRM_PAGE_SIZE;
+    info->ringReadMapSize = r128_drm_page_size;
 
 				/* Reserve space for vertex/indirect buffers */
     info->bufStart        = info->ringReadOffset + info->ringReadMapSize;
@@ -907,6 +901,8 @@
     case 32:
 	break;
     }
+
+    r128_drm_page_size = getpagesize();
 
     /* Create the DRI data structure, and fill it in before calling the
        DRIScreenInit(). */

