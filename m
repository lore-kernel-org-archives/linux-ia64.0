From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 18 Aug 2000 07:38:36 +0000
Subject: [Linux-ia64] final DRI/DRM patch: tdfx updates
Message-Id: <marc-linux-ia64-105590678205355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The final piece of patches you need to get 3dfx support in the
XFree86-4.0 server is the patch below.  The tdfx driver included in
XFree86-4.0 didn't compile for me, so what I had to do is take the
source code out of the tdfx_dri-4.0.00-3.src.rpm RPM available from
3dfx and stick it into the standard XFree86-4.0 (just copying the
stuff in xc/programs/Xserver/hw/xfree86/drivers/tdfx should be
sufficient).

Unfortunately, there seem to be some incompatibilities between the
tdfx_dri RPM and the official XFree86 RPM.  The patch below should fix
those incompatibilities.  Also, I didn't try to build the "int10" and
"vbe" modules, so I simply commented them out from the 3dfx driver.

	--david

diff -urN tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx.h XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx.h
--- tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx.h	Sun Jun 11 19:33:12 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx.h	Wed Aug  9 04:27:39 2000
@@ -149,8 +149,8 @@
   int MaxClock;
   int ChipType;
   pciVideoPtr PciInfo;
-  int LinearAddr[MAXCHIPS];
-  int MMIOAddr[MAXCHIPS];
+  unsigned int LinearAddr[MAXCHIPS];
+  unsigned int MMIOAddr[MAXCHIPS];
   EntityInfoPtr pEnt;
   int numChips;
   PCITAG PciTag[MAXCHIPS];
diff -urN tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_accel.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_accel.c
--- tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_accel.c	Fri Jul  7 12:14:56 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_accel.c	Wed Aug  9 04:38:01 2000
@@ -144,6 +144,7 @@
     TDFXWriteLong(pTDFX, SST_2D_SRCFORMAT, fmt);
     break;
   default:
+    break;
   }
 }
 
diff -urN tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_dri.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_dri.c
--- tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_dri.c	Sun Jun 11 19:33:12 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_dri.c	Thu Aug 10 10:19:27 2000
@@ -115,10 +117,14 @@
 	      pConfigs[i].stencilSize = 0;
 	    pConfigs[i].auxBuffers = 0;
 	    pConfigs[i].level = 0;
+#if 0 /* XXX --davidm 00/08/09 */
 	    if (stencil || accum)
 	      pConfigs[i].visualRating = GLX_SLOW_VISUAL_EXT;
 	    else
 	      pConfigs[i].visualRating = GLX_NONE_EXT;
+#else
+	    pConfigs[i].visualRating = 0;
+#endif
 	    pConfigs[i].transparentPixel = 0;
 	    pConfigs[i].transparentRed = 0;
 	    pConfigs[i].transparentGreen = 0;
@@ -209,10 +215,14 @@
 	      pConfigs[i].stencilSize = 0;
 	    pConfigs[i].auxBuffers = 0;
 	    pConfigs[i].level = 0;
+#if 0 /* XXX --davidm 00/08/09 */
 	    if (accum)
 	      pConfigs[i].visualRating = GLX_SLOW_VISUAL_EXT;
 	    else
 	      pConfigs[i].visualRating = GLX_NONE_EXT;
+#else
+	    pConfigs[i].visualRating = 0;
+#endif
 	    pConfigs[i].transparentPixel = 0;
 	    pConfigs[i].transparentRed = 0;
 	    pConfigs[i].transparentGreen = 0;
@@ -283,6 +293,10 @@
     if (!LoaderSymbol("drmAvailable"))        return FALSE;
 #endif
 
+#if 0
+    /* DRIQueryVersion() doesn't seem to exist anymore.  There is
+       XF86DRIQueryVersion() but it has a slightly different interface
+       and returns 1 as the major number.  Duh. --davidm 00/08/08 */
   /* Check the DRI version */
   {
     int major, minor, patch;
@@ -294,6 +308,7 @@
       return FALSE;
     }
   }
+#endif
 
   pDRIInfo = DRICreateInfoRec();
   if (!pDRIInfo)
diff -urN tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_driver.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_driver.c
--- tdfx_dri-4.0.00/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_driver.c	Fri Jul  7 12:14:56 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/drivers/tdfx/tdfx_driver.c	Tue Aug  8 23:28:00 2000
@@ -331,7 +331,10 @@
 	 * might refer to.
 	 */
 	LoaderRefSymLists(vgahwSymbols, cfbSymbols, xaaSymbols, 
-			  xf8_32bppSymbols, ramdacSymbols, vbeSymbols,
+			  xf8_32bppSymbols, ramdacSymbols,
+#ifndef __ia64__
+			  vbeSymbols,
+#endif
 #ifdef XF86DRI
 			  drmSymbols, driSymbols,
 #endif
@@ -535,11 +538,13 @@
 static void
 TDFXProbeDDC(ScrnInfoPtr pScrn, int index)
 {
+#ifndef __ia64__
     vbeInfoPtr pVbe;
     if (xf86LoadSubModule(pScrn, "vbe")) {
         pVbe = VBEInit(NULL,index);
         ConfiguredMonitor = vbeDoEDID(pVbe);
     }
+#endif
 }
 
 static int TDFXCfgToSize(int cfg)
@@ -669,6 +674,8 @@
   /* Allocate a vgaHWRec */
   if (!vgaHWGetHWRec(pScrn)) return FALSE;
 
+#ifndef __ia64__
+  /* xxx notyet */
   if (xf86LoadSubModule(pScrn, "int10")) {
     xf86Int10InfoPtr pInt;
     xf86DrvMsg(pScrn->scrnIndex, X_INFO, 
@@ -686,6 +693,7 @@
       xf86FreeInt10(pInt);
     }
   }
+#endif
 
   match=pTDFX->PciInfo=xf86GetPciInfoForEntity(pTDFX->pEnt->index);
   TDFXFindChips(pScrn, match);
@@ -966,11 +974,13 @@
   xf86LoaderReqSymLists(ddcSymbols, NULL);
 
   /* Initialize DDC1 if possible */
+#ifndef __ia64__
   if (xf86LoadSubModule(pScrn, "vbe")) {
       xf86MonPtr pMon;
       pMon = vbeDoEDID(VBEInit(NULL,pTDFX->pEnt->index));
       xf86SetDDCproperties(pScrn,xf86PrintEDID(pMon));
   }
+#endif
 
   if (xf86ReturnOptValBool(TDFXOptions, OPTION_USE_PIO, FALSE)) {
     pTDFX->usePIO=TRUE;

