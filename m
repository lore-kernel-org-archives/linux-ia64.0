From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 18 Aug 2000 07:08:02 +0000
Subject: [Linux-ia64] 64-bit fixes for DRI/DRM
Message-Id: <marc-linux-ia64-105590678205353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here are a couple of fixes that improve the 64-bit support, tdfx
support, and general portability of DRI/DRM.  I'm afraid the patch is
relative to XFree86-4.0 as found in Red Hat's
XFree86-4.0-0.21.src.rpm.  I hope not too much has changed in the area
the patches touch upon so this may still be of use.

While doing the initial Glide testing (in standalone, instead of DRI
mode), I noticed that in xf86vmstr.h, the xXF86VidModeModeInfo seems
to be wrong.  It looks like this:

typedef struct {
    CARD32      dotclock B32;
    CARD16      hdisplay B16;
    CARD16      hsyncstart B16;
    CARD16      hsyncend B16;
    CARD16      htotal B16;
    CARD32      hskew B16;
    CARD16      vdisplay B16;
    CARD16      vsyncstart B16;
    CARD16      vsyncend B16;
    CARD16      vtotal B16;
    CARD16      pad1 B16;
    CARD32      flags B32;
    CARD32      reserved1 B32;
    CARD32      reserved2 B32;
    CARD32      reserved3 B32;
    CARD32      privsize B32;
} xXF86VidModeModeInfo;

Note that there are _five_ CARD16 values between "hskew" and "flags",
causing "flags" to be misaligned on some platforms.  Seems to me that
"pad1" is extraneous.  I don't know how to fix this without breaking
backwards compatibility, so the patch below doesn't do anything about
this.

Here is a summary/rationale for the changes in the patch below:

 extras/Mesa/src/FX/fxddspan.c:
	I don't know what I'm doing here, but I took this change from
	the tdfx X server (as distributed by 3Dfx).  Without this
	change, FlightGear would segfault immediately when running in
	full screen mode (--enable-game-mode).

 xc/lib/GL/Imakefile:
	Include files in X86 subdirectory only if i386Architecture is
	defined.

 xc/lib/GL/dri/XF86dri.c:
	Add missing | operator so that we get the top 32 bits of the
	frame buffer address, too.

 xc/lib/GL/dri/XF86dri.c:
 xc/lib/Xxf86vm/XF86Vmode.c:
	Replace _XRead32() by _XRead().  It is my understanding that
	_XRead32() is intended to be used to return 32-bit values in a
	"long *" array.  The read calls that I changed all just want
	to read the next N bytes, so _XRead() seems like the right
	thing here.  The old code definitely was wrong on IA-64 as it
	distributed each 32-bit quantity on the wire into a 64-bit
	quantity in memory.

  xc/lib/GL/glx/packsingle.h:
	Remove trailing whitespace after backslash (causes a harmless
	but annoying warning otherwise).

  xc/lib/GL/mesa/src/Imakefile:
	Include X86 subdirectory only if i386Architecture is defined.

  xc/programs/Xserver/hw/xfree86/common/compiler.h:
	Do NOT include any Linux kernel headers.  No application
	should ever do this as it will quickly cause the application
	when the kernel changes.  Please use only glibc headers in
	applications.  (You can get rid of the code inside #if 0, of
	course...).

  xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile
	Use same PCI code as on Alpha.  It might be a good idea rename
	axpPci.c to something more generic.  Both Alpha and IA-64 use
	the same system calls to access PCI configuration space.
	Perhaps LinuxPci.c or LinuxSysPci.c would be appropriate?

  xc/programs/Xserver/hw/xfree86/os-support/bus/Pci.h
	Increase MAX_PCI_BUSES from 32 to 256.

  xc/programs/Xserver/hw/xfree86/os-support/bus/axpPci.c
	Scan all 256 buses.  In general, the PCI subsystem consists of
	a forest of buses (not just a single tree) so the only way to
	reliably detect all buses is to scan all possible roots.  This
	should be re-tested on Alpha to make sure the change doesn't
	have any bad side-effects (it shouldn't, but...).

  xc/programs/Xserver/hw/xfree86/os-support/linux/drm/xf86drm.c
	Round "size" argument of drmMap() up to next page size.  The
	mmap() call will fail if the map size isn't an integer
	multiple of the system's page size.  I suppose we could change
	the call-sites of drmMap() instead, however, given that
	drmMap() does not specify the address _where_ the buffer get
	mapped, it didn't make a whole lot of sense to require the
	caller to know the page size.

   xc/programs/Xserver/hw/xfree86/os-support/shared/libc_wrapper.c:
	Drop include of <asm/page.h>.  Again, including Linux kernel
	headers is a no-no.

   xc/programs/Xserver/hw/xfree86/os-support/xf86drm.h
	Add compare-and-swap definition for IA-64.  Also change
	generic version of DRM_CAS so that compilation with it will
	fail.  The generic code is broken, so there it does not make
	much sense to pretend otherwise (e.g., to really work, the
	generic DRM_CAS() would at least have to assign a value to
	"ret").

Note: this patch won't give you a working DRI/DRM for IA-64 Linux.
I'll be sending a complete diff to the IA-64 kernel list
(linux-ia64@linuxia64.org) in a short while.  The stuff I excluded
here is basically configuration changes that are not terribly
clean/need more work.

	--david

diff -urN XFree86-4.0/xc/extras/Mesa/src/FX/fxddspan.c XFree86-4.0-lia/xc/extras/Mesa/src/FX/fxddspan.c
--- XFree86-4.0/xc/extras/Mesa/src/FX/fxddspan.c	Thu Feb 17 09:11:31 2000
+++ XFree86-4.0-lia/xc/extras/Mesa/src/FX/fxddspan.c	Fri Aug 11 00:16:03 2000
@@ -396,7 +396,7 @@
 {
   fxMesaContext fxMesa=(fxMesaContext)ctx->DriverCtx;
   GLuint i;
-  GLint bottom=fxMesa->y_delta-1;
+  GLint bottom=fxMesa->height+fxMesa->y_offset-1;
 
   if (MESA_VERBOSE&VERBOSE_DRIVER) {
      fprintf(stderr,"fxmesa: fxDDReadRGBAPixels(...)\n");
diff -urN XFree86-4.0/xc/lib/GL/Imakefile XFree86-4.0-lia/xc/lib/GL/Imakefile
--- XFree86-4.0/xc/lib/GL/Imakefile	Fri Mar  3 20:37:25 2000
+++ XFree86-4.0-lia/xc/lib/GL/Imakefile	Thu Aug 10 00:45:25 2000
@@ -79,11 +79,18 @@
    TDFXPOBJS = mesa/src/drv/tdfx/profiled/?*.o
    TDFXDONES = mesa/src/drv/tdfx/DONE
 
-    MESAOBJS = mesa/src/?*.o mesa/src/X86/?*.o
-   MESAUOBJS = mesa/src/unshared/?*.o mesa/src/X86/unshared/?*.o
-   MESADOBJS = mesa/src/debugger/?*.o mesa/src/X86/debugger/?*.o
-   MESAPOBJS = mesa/src/profiled/?*.o mesa/src/X86/profiled/?*.o
-   MESADONES = mesa/src/DONE mesa/src/X86/DONE
+#ifdef i386Architecture
+   MESAOBJSARCH = mesa/src/X86/?*.o
+   MESAUOBJSARCH = mesa/src/X86/unshared/?*.o
+   MESADOBJSARCH = mesa/src/X86/debugger/?*.o
+   MESAPOBJSARCH = mesa/src/X86/profiled/?*.o
+   MESADONESARCH = mesa/src/X86/DONE
+#endif
+   MESAOBJS = mesa/src/?*.o $(MESAOBJSARCH)
+   MESAUOBJS = mesa/src/unshared/?*.o $(MESAUOBJSARCH)
+   MESADOBJS = mesa/src/debugger/?*.o $(MESADOBJSARCH)
+   MESAPOBJS = mesa/src/profiled/?*.o $(MESAPOBJSARCH)
+   MESADONES = mesa/src/DONE $(MESADONEARCH)
 
  DRIMESAOBJS = mesa/dri/?*.o
 DRIMESAUOBJS = mesa/dri/unshared/?*.o
diff -urN XFree86-4.0/xc/lib/GL/dri/XF86dri.c XFree86-4.0-lia/xc/lib/GL/dri/XF86dri.c
--- XFree86-4.0/xc/lib/GL/dri/XF86dri.c	Fri Feb 25 21:35:26 2000
+++ XFree86-4.0-lia/xc/lib/GL/dri/XF86dri.c	Thu Aug 10 17:24:44 2000
@@ -427,7 +427,7 @@
             _XEatData(dpy, rep.length);
             return False;
         }
-	_XRead32(dpy, *pClipRects, rep.length);
+	_XRead(dpy, (char *) *pClipRects, rep.length);
     } else {
         *pClipRects = NULL;
     }
@@ -466,7 +466,7 @@
 
     *hFrameBuffer = rep.hFrameBufferLow;
 #ifdef LONG64
-    *hFrameBuffer = ((drmHandle)rep.hFrameBufferHigh) << 32;
+    *hFrameBuffer |= ((drmHandle)rep.hFrameBufferHigh) << 32;
 #endif
 
     *fbOrigin = rep.framebufferOrigin;
@@ -479,7 +479,7 @@
             _XEatData(dpy, ((rep.length+3) & ~3));
             return False;
         }
-	_XRead32(dpy, *pDevPrivate, rep.length);
+	_XRead(dpy, *pDevPrivate, rep.length);
     } else {
         *pDevPrivate = NULL;
     }
diff -urN XFree86-4.0/xc/lib/GL/glx/packsingle.h XFree86-4.0-lia/xc/lib/GL/glx/packsingle.h
--- XFree86-4.0/xc/lib/GL/glx/packsingle.h	Wed Feb  9 09:55:02 2000
+++ XFree86-4.0-lia/xc/lib/GL/glx/packsingle.h	Thu Aug 10 16:27:07 2000
@@ -85,7 +85,7 @@
     *((FLOAT32 *) (pc + offset)) = a
 
 #else
-#define __GLX_SINGLE_PUT_SHORT(offset,a) \     
+#define __GLX_SINGLE_PUT_SHORT(offset,a) \
     { GLubyte *cp = (pc+offset); \
       int shift = (64-16) - ((int)(cp) >> (64-6)); \
       *(int *)cp = (*(int *)cp & ~(0xffff << shift)) | ((a & 0xffff) << shift); }
diff -urN XFree86-4.0/xc/lib/GL/mesa/src/Imakefile XFree86-4.0-lia/xc/lib/GL/mesa/src/Imakefile
--- XFree86-4.0/xc/lib/GL/mesa/src/Imakefile	Fri Mar  3 20:37:28 2000
+++ XFree86-4.0-lia/xc/lib/GL/mesa/src/Imakefile	Tue Aug  8 14:44:06 2000
@@ -354,7 +354,9 @@
 # We have to go into X to make the xmesaP.h symbolic link
   MESASUBDIRS = X
 
+#ifdef i386Architecture
   ASMSUBDIRS = X86
+#endif
 
 #include <Library.tmpl>
 
@@ -374,8 +376,13 @@
 
 #if !GlxUseBuiltInDRIDriver && !GlxDriverUsesMesa
 LIBNAME = mesa_dri.so
-ALL_OBJS = $(CORE_OBJS) X/?*.o X86/?*.o
-ALL_DEPS = $(SUBDIRS) DONE X/DONE X86/DONE
+#ifdef i386Architecture
+ ALL_OBJS = $(CORE_OBJS) X/?*.o X86/?*.o
+ ALL_DEPS = $(SUBDIRS) DONE X/DONE X86/DONE
+#else
+ ALL_OBJS = $(CORE_OBJS) X/?*.o
+ ALL_DEPS = $(SUBDIRS) DONE X/DONE
+#endif
 SharedDepModuleTarget($(LIBNAME),$(ALL_DEPS),$(ALL_OBJS))
 InstallDynamicModule($(LIBNAME),$(MODULEDIR)/dri,.)
diff -urN XFree86-4.0/xc/lib/Xxf86vm/XF86VMode.c XFree86-4.0-lia/xc/lib/Xxf86vm/XF86VMode.c
--- XFree86-4.0/xc/lib/Xxf86vm/XF86VMode.c	Mon Jul 19 08:01:32 1999
+++ XFree86-4.0-lia/xc/lib/Xxf86vm/XF86VMode.c	Wed Aug  9 16:15:22 2000
@@ -278,7 +278,7 @@
 	    Xfree(modeline->private);
 	    return False;
 	}
-	_XRead32(dpy, modeline->private, rep.privsize * sizeof(INT32));
+	_XRead(dpy, (char *) modeline->private, rep.privsize * sizeof(INT32));
     } else {
 	modeline->private = NULL;
     }
@@ -354,7 +354,7 @@
     for (i = 0; i < rep.modecount; i++) {
         modelines[i] = mdinfptr++;
 	if (majorVersion < 2) {
-            _XRead32(dpy, &oldxmdline, sizeof(xXF86OldVidModeModeInfo));
+            _XRead(dpy, (char *) &oldxmdline, sizeof(xXF86OldVidModeModeInfo));
 	    modelines[i]->dotclock   = oldxmdline.dotclock;
 	    modelines[i]->hdisplay   = oldxmdline.hdisplay;
 	    modelines[i]->hsyncstart = oldxmdline.hsyncstart;
@@ -377,7 +377,7 @@
 			_XEatData(dpy, (oldxmdline.privsize) * sizeof(INT32));
 			Xfree(modelines[i]->private);
 		    } else {
-			_XRead32(dpy, modelines[i]->private,
+			_XRead(dpy, (char *) modelines[i]->private,
 			     oldxmdline.privsize * sizeof(INT32));
 		    }
 		} else {
@@ -385,7 +385,7 @@
 		}
 	    }
 	} else {
-            _XRead32(dpy, &xmdline, sizeof(xXF86VidModeModeInfo));
+            _XRead(dpy, (char *) &xmdline, sizeof(xXF86VidModeModeInfo));
 	    modelines[i]->dotclock   = xmdline.dotclock;
 	    modelines[i]->hdisplay   = xmdline.hdisplay;
 	    modelines[i]->hsyncstart = xmdline.hsyncstart;
@@ -408,7 +408,7 @@
 			_XEatData(dpy, (xmdline.privsize) * sizeof(INT32));
 			Xfree(modelines[i]->private);
 		    } else {
-			_XRead32(dpy, modelines[i]->private,
+			_XRead(dpy, (char *) modelines[i]->private,
 			     xmdline.privsize * sizeof(INT32));
 		    }
 		} else {
@@ -962,12 +962,12 @@
 	return False;
     }
     for (i = 0; i < rep.nhsync; i++) {
-	_XRead32(dpy, (long *)&syncrange, 4);
+	_XRead(dpy, (char *)&syncrange, 4);
 	monitor->hsync[i].lo = (float)(syncrange & 0xFFFF) / 100.0;
 	monitor->hsync[i].hi = (float)(syncrange >> 16) / 100.0;
     }
     for (i = 0; i < rep.nvsync; i++) {
-	_XRead32(dpy, (long *)&syncrange, 4);
+	_XRead(dpy, (char *)&syncrange, 4);
 	monitor->vsync[i].lo = (float)(syncrange & 0xFFFF) / 100.0;
 	monitor->vsync[i].hi = (float)(syncrange >> 16) / 100.0;
     }
@@ -1100,7 +1100,7 @@
     }
 
     for (i = 0; i < rep.clocks; i++) {
-        _XRead32(dpy, &dotclk, 4);
+        _XRead(dpy, (char *) &dotclk, 4);
 	dotclocks[i] = dotclk;
     }
     *clocksPtr = dotclocks;
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/common/compiler.h XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/common/compiler.h
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/common/compiler.h	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/common/compiler.h	Wed Aug  9 00:25:22 2000
@@ -365,14 +365,65 @@
 
 
 #elif defined(linux) && defined(__ia64__) 
-#define inline __inline__
- 
-#include <stdlib.h>
-#include <asm/types.h>
-#include <asm/system.h>
+#if 0
+/* Geez, bogus stuff!! Must never include kernel headers in
+   applications... */
+# include <stdlib.h>
+# include <asm/types.h>
+# include <asm/system.h>
+# include <asm/unaligned.h>
+#endif
+
+#include <inttypes.h>
+
 #include <sys/io.h>
-#include <asm/unaligned.h>
   
+struct __una_u64 { uint64_t x __attribute__((packed)); };
+struct __una_u32 { uint32_t x __attribute__((packed)); };
+struct __una_u16 { uint16_t x __attribute__((packed)); };
+
+extern __inline__ unsigned long
+__uldq (const unsigned long * r11)
+{
+	const struct __una_u64 *ptr = (const struct __una_u64 *) r11;
+	return ptr->x;
+}
+
+extern __inline__ unsigned long
+__uldl (const unsigned int * r11)
+{
+	const struct __una_u32 *ptr = (const struct __una_u32 *) r11;
+	return ptr->x;
+}
+
+extern __inline__ unsigned long
+__uldw (const unsigned short * r11)
+{
+	const struct __una_u16 *ptr = (const struct __una_u16 *) r11;
+	return ptr->x;
+}
+
+extern __inline__ void
+__ustq (unsigned long r5, unsigned long * r11)
+{
+	struct __una_u64 *ptr = (struct __una_u64 *) r11;
+	ptr->x = r5;
+}
+
+extern __inline__ void
+__ustl (unsigned long r5, unsigned int * r11)
+{
+	struct __una_u32 *ptr = (struct __una_u32 *) r11;
+	ptr->x = r5;
+}
+
+extern __inline__ void
+__ustw (unsigned long r5, unsigned short * r11)
+{
+	struct __una_u16 *ptr = (struct __una_u16 *) r11;
+	ptr->x = r5;
+}
+
 #define ldq_u(p)        __uldq(p)
 #define ldl_u(p)        __uldl(p)
 #define ldw_u(p)        __uldw(p) 
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile	Wed Aug  9 00:08:39 2000
@@ -44,7 +44,7 @@
 PCIDRVRSRC = freebsdPci.c
 PCIDRVROBJ = freebsdPci.o
 
-#elif defined(i386Architecture) || defined(ia64Architecture)
+#elif defined(i386Architecture)
 
 XCOMM ix86 PCI driver
 
@@ -52,6 +52,15 @@
 PCIDRVROBJ = ix86Pci.o
 XCOMM PCIDRVRSRC = linuxPci.c
 XCOMM PCIDRVROBJ = linuxPci.o
+
+#elif defined(ia64Architecture)
+
+XCOMM Not a typo, just a misnomer.  For Linux/ia64 provides the same
+XCOMM PCI config read/write syscalls as Linux/alpha, so why not use
+XCOMM them?
+
+PCIDRVRSRC = axpPci.c
+PCIDRVROBJ = axpPci.o
 
 #else
 XCOMM no PCI driver -- shouldn't get here
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/Pci.h XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/Pci.h
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/Pci.h	Sat Feb 12 23:53:02 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/Pci.h	Wed Aug  9 01:58:54 2000
@@ -85,7 +85,7 @@
  */
 #define MAX_PCI_DEVICES 64	/* Max number of devices accomodated */
 				/* by xf86scanpci		     */
-#define MAX_PCI_BUSES   32	/* Max number of PCI buses           */
+#define MAX_PCI_BUSES   256	/* Max number of PCI buses           */
 
 #define PCI_NOT_FOUND   0xffffffff
 
@@ -146,7 +147,7 @@
 # endif
 #elif defined(__sparc__) && defined(linux)
 # define ARCH_PCI_INIT sparcPciInit
-#elif defined(__alpha__) && defined(linux)
+#elif (defined(__alpha__) || defined(__ia64__)) && defined(linux)
 # define ARCH_PCI_INIT axpPciInit
 # define INCLUDE_XF86_MAP_PCI_MEM
 #elif defined(__alpha__) && defined(__FreeBSD__)
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/axpPci.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/axpPci.c
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/bus/axpPci.c	Sun Dec  5 19:07:39 1999
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/bus/axpPci.c	Wed Aug  9 01:53:06 2000
@@ -61,6 +61,7 @@
 void axpPciCfgWrite(PCITAG, int off, CARD32 val);
 void axpPciCfgSetBits(PCITAG tag, int off, CARD32 mask, CARD32 bits);
 
+#if 0
 pciBusInfo_t axpPci0 = {
 /* configMech  */	  PCI_CFG_MECH_OTHER,
 /* numDevices  */	  32,
@@ -77,12 +78,32 @@
 		          },
 /* pciBusPriv  */	  NULL
 };
+#else
+pciBusInfo_t axpPci[MAX_PCI_BUSES];
+#endif
 
 void  
 axpPciInit()
 {
+#if 0
   pciNumBuses    = 1;
   pciBusInfo[0]  = &axpPci0;
+#else
+  int i;
+
+  pciNumBuses    = MAX_PCI_BUSES;
+  memset(&axpPci, 0, sizeof(axpPci));
+  for (i = 0; i < MAX_PCI_BUSES; ++i) {
+	  axpPci[i].configMech = PCI_CFG_MECH_OTHER;
+	  axpPci[i].numDevices = 32;
+	  axpPci[i].funcs.pciReadLong = axpPciCfgRead;
+	  axpPci[i].funcs.pciWriteLong = axpPciCfgWrite;
+	  axpPci[i].funcs.pciSetBitsLong = axpPciCfgSetBits;
+	  axpPci[i].funcs.pciAddrHostToBus = pciAddrNOOP;
+	  axpPci[i].funcs.pciAddrBusToHost = pciAddrNOOP;
+	  pciBusInfo[i] = axpPci + i;
+  }
+#endif
   pciFindFirstFP = pciGenFindFirst;
   pciFindNextFP  = pciGenFindNext;
 }
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/linux/drm/xf86drm.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/linux/drm/xf86drm.c
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/linux/drm/xf86drm.c	Fri Feb 25 21:43:53 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/linux/drm/xf86drm.c	Thu Aug 10 15:55:13 2000
@@ -497,7 +497,15 @@
 	   drmSize size,
 	   drmAddressPtr address)
 {
+    static unsigned long pagesize_mask = 0;
+
     if (fd < 0) return -EINVAL;
+
+    if (!pagesize_mask)
+	pagesize_mask = getpagesize() - 1;
+
+    size = (size + pagesize_mask) & ~pagesize_mask;
+
     *address = mmap(0, size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, handle);
     if (*address = MAP_FAILED) return -errno;
     return 0;
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/shared/libc_wrapper.c XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/shared/libc_wrapper.c
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/shared/libc_wrapper.c	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/shared/libc_wrapper.c	Wed Aug  9 00:15:57 2000
@@ -143,7 +143,9 @@
 
 /* For xf86getpagesize() */
 #if defined(linux)
+#if 0
 #include <asm/page.h>
+#endif
 #define HAS_SC_PAGESIZE
 #define HAS_GETPAGESIZE
 #elif defined(CSRG_BASED)
diff -urN XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/xf86drm.h XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/xf86drm.h
--- XFree86-4.0/xc/programs/Xserver/hw/xfree86/os-support/xf86drm.h	Fri Feb 25 21:43:46 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/hw/xfree86/os-support/xf86drm.h	Thu Aug 10 18:32:35 2000
@@ -179,7 +179,8 @@
 #define DRM_LOCK_HELD  0x80000000 /* Hardware lock is held                 */
 #define DRM_LOCK_CONT  0x40000000 /* Hardware lock is contended            */
 
-#if __GNUC__ >= 2 && defined(__i386)
+#if __GNUC__ >= 2
+# if defined(__i386)
 				/* Reflect changes here to drmP.h */
 #define DRM_CAS(lock,old,new,__ret)                                    \
 	do {                                                           \
@@ -193,10 +194,40 @@
 			: "2" (old),                                   \
 			  "r" (new));                                  \
 	} while (0)
+
+# elif defined (__ia64__)
+
+#if 0
+/* this currently generates bad code (missing stop bits)... */
+#include <ia64intrin.h>
+
+#define DRM_CAS(lock,old,new,__ret)					      \
+	do {								      \
+		__ret = (__sync_val_compare_and_swap(&__drm_dummy_lock(lock), \
+						     (old), (new))	      \
+			 != (old));					      \
+	} while (0)
+
+#else
+#define DRM_CAS(lock,old,new,__ret)					  \
+	do {								  \
+		unsigned int __result, __old = (old);			  \
+		__asm__ __volatile__(					  \
+			"mf\n"						  \
+			"mov ar.ccv=%2\n"				  \
+			";;\n"						  \
+			"cmpxchg4.acq %0=%1,%3,ar.ccv"			  \
+			: "=r" (__result), "=m" (__drm_dummy_lock(lock))  \
+			: "r" (__old), "r" (new)			  \
+			: "memory");					  \
+		__ret = (__result) != (__old);				  \
+	} while (0)
 #endif
+# endif /* __ia64__ */
+#endif /* __GNUC__ >= 2 */
 
 #ifndef DRM_CAS
-#define DRM_CAS(lock,old,new,ret) /* FAST LOCK FAILS */
+#define DRM_CAS(lock,old,new,ret) /* FAST LOCK FAILS */ THIS IS BROKEN!!!
 #endif
 
 #define DRM_LIGHT_LOCK(fd,lock,context)                                \

