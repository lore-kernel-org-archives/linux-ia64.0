From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 18 Aug 2000 07:33:09 +0000
Subject: [Linux-ia64] complete fixes for DRI/DRM
Message-Id: <marc-linux-ia64-105590678205354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below is a superset of what I just sent to the
fixes@xfree86.org list.  It include the config changes necessary to
get the GL/DRI/TDFX support built.

The way this config is setup, you'll get the DRI drivers built into
libGl instead of having them as separate modules.  I didn't try
building them as modules, though I hope it would work just fine.

	--david

diff -urN XFree86-4.0/xc/config/cf/host.def XFree86-4.0-lia/xc/config/cf/host.def
--- XFree86-4.0/xc/config/cf/host.def	Thu Aug 17 22:07:39 2000
+++ XFree86-4.0-lia/xc/config/cf/host.def	Tue Aug  8 15:48:55 2000
@@ -9,5 +9,5 @@
 #define BuildPexExt YES
 #define BuildHtmlManPages NO
 #define MakeDllModules YES
-#define GlxStubLib YES
+#define GlxStubLib NO
 #define UseInternalMalloc NO
diff -urN XFree86-4.0/xc/config/cf/linux.cf XFree86-4.0-lia/xc/config/cf/linux.cf
--- XFree86-4.0/xc/config/cf/linux.cf	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/config/cf/linux.cf	Wed Aug  9 02:52:03 2000
@@ -161,7 +161,7 @@
 #ifndef XF86INT10_BUILD
 # ifdef i386Architecture
 #  define XF86INT10_BUILD X86VM
-# elif defined(ia64Architecture)
+# elif 0/*defined(ia64Architecture)*/
 #  define UseX86Emu NO
 #  define XF86INT10_BUILD XF86INT10_STUB
 # elif defined(X86EMU_LIBPATH)
@@ -172,7 +172,7 @@
 /* The DRM module requires kernel services that appeared in late 2.1.x
    kernels and are known to be present in 2.2.x kernels. */
 #ifndef BuildXF86DRI
-#  ifdef i386Architecture
+#  if defined(i386Architecture) || defined(ia64Architecture)
 #    if OSMajorVersion > 2 || (OSMajorVersion = 2 && OSMinorVersion >= 2)
 #      define BuildXF86DRI            YES
 #    else
@@ -189,7 +189,7 @@
    kernel revisions.  So, we'll only build the module for kernels that are
    known to be supported by the module. */
 #ifndef BuildXF86DRM
-#  ifdef i386Architecture
+#  if defined(i386Architecture) || defined(ia64Architecture)
 #    if OSMajorVersion = 2
        /* Only tested for Linux 2.2.0 through 2.2.12 */
 #      if OSMinorVersion = 2 && OSTeenyVersion <= 12
@@ -199,8 +199,12 @@
 #        if OSMinorVersion = 3 && OSTeenyVersion <= 18
 #          define BuildXF86DRM      YES
 #        else
-           /* Note: add more conditions when 2.4.x and 2.5.x are released */
-#          define BuildXF86DRM      NO
+#	   if OSMinorVersion = 4
+#            define BuildXF86DRM      NO
+#	   else
+             /* Note: add more conditions when 2.5.x is released */
+#            define BuildXF86DRM      NO
+#	   endif
 #        endif
 #      endif
 #    else
@@ -213,7 +217,7 @@
 #endif
 
 #ifndef HasAgpGart
-#  ifdef i386Architecture
+#  if defined(i386Architecture) || defined(ia64Architecture)
      /* The AGPGART header file is included in os-support/linux, which
         allows all drivers that depend on AGP to build properly. */
 #    define HasAgpGart              YES
diff -urN XFree86-4.0/xc/config/cf/xf86site.def XFree86-4.0-lia/xc/config/cf/xf86site.def
--- XFree86-4.0/xc/config/cf/xf86site.def	Thu Aug 17 22:07:39 2000
+++ XFree86-4.0-lia/xc/config/cf/xf86site.def	Wed Aug  9 02:52:50 2000
@@ -680,7 +680,7 @@
  * If your system doesn't support vm86() mode and you have
  * libx86emu set library path here
  *
-#define X86EMU_LIBPATH /usr/local/lib
  */ 
+#define X86EMU_LIBPATH /usr/local/lib
 
 
diff -urN XFree86-4.0/xc/config/cf/xfree86.cf XFree86-4.0-lia/xc/config/cf/xfree86.cf
--- XFree86-4.0/xc/config/cf/xfree86.cf	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/config/cf/xfree86.cf	Tue Aug  8 15:38:05 2000
@@ -234,7 +234,7 @@
 
 /* Pure PCI drivers should go first */
 # ifndef XF86CardDrivers
-#  define XF86CardDrivers	mga vga
+#  define XF86CardDrivers	mga vga GlideDriver tdfx r128 AgpGartDrivers XF86ExtraCardDrivers
 # endif
 #endif
 
@@ -549,7 +549,7 @@
 #    define GlxBuiltInMesa         NO
 #  endif
 #  ifndef GlxBuiltInTdfx
-#    define GlxBuiltInTdfx         NO
+#    define GlxBuiltInTdfx         YES
 #  endif
 
 #  if GlxBuiltInTdfx
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
diff -urN XFree86-4.0/xc/extras/x86emu/src/x86emu/makefile.lia64 XFree86-4.0-lia/xc/extras/x86emu/src/x86emu/makefile.lia64
--- XFree86-4.0/xc/extras/x86emu/src/x86emu/makefile.lia64	Wed Dec 31 16:00:00 1969
+++ XFree86-4.0-lia/xc/extras/x86emu/src/x86emu/makefile.lia64	Wed Aug  9 04:00:05 2000
@@ -0,0 +1,60 @@
+#############################################################################
+#
+#						Realmode X86 Emulator Library
+#
+#            	Copyright (C) 1996-1999 SciTech Software, Inc.
+#
+#  ====================================
+#
+#  Permission to use, copy, modify, distribute, and sell this software and
+#  its documentation for any purpose is hereby granted without fee,
+#  provided that the above copyright notice appear in all copies and that
+#  both that copyright notice and this permission notice appear in
+#  supporting documentation, and that the name of the authors not be used
+#  in advertising or publicity pertaining to distribution of the software
+#  without specific, written prior permission.  The authors makes no
+#  representations about the suitability of this software for any purpose.
+#  It is provided "as is" without express or implied warranty.
+#
+#  THE AUTHORS DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
+#  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
+#  EVENT SHALL THE AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
+#  CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
+#  USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
+#  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
+#  PERFORMANCE OF THIS SOFTWARE.
+#
+#  ====================================
+#
+# Descripton:   Linux specific makefile for the x86emu library.
+#
+#############################################################################
+
+TARGETLIB = libx86emu.a
+
+OBJS=\
+debug.o \
+decode.o \
+fpu.o \
+ops.o \
+ops2.o \
+prim_ops.o \
+sys.o
+
+$(TARGETLIB): $(OBJS)
+	ar rv $(TARGETLIB) $(OBJS)
+
+INCS   = -I. -Ix86emu -I../../include
+CFLAGS = -D__DRIVER__ -DFORCE_POST -D_CEXPORT= -DDEBUG
+
+.c.o:
+	gcc -g -O2 -Wall -c $(CFLAGS) $(INCS) $*.c
+
+.cpp.o:
+	gcc -c $(CFLAGS) $(INCS) $*.cpp
+
+clean:
+	rm -f *.a *.o
+
+validate:	validate.o libx86emu.a
+	gcc -o validate validate.o -lx86emu -L.
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
@@ -97,7 +104,7 @@
     DRVPOBJS = $(TDFXPOBJS) $(MESAPOBJS) $(DRIMESAPOBJS) $(DRMPOBJS)
     DRVDONES = $(TDFXDONES) $(MESADONES) $(DRIMESADONES) $(DRMDONES)
 
- REQUIREDLIBS += -lglide3x
+ REQUIREDLIBS += -L/usr/local/lib -lglide3x
 #elif GlxBuiltInMesa
 #ifndef GlxDriverUsesMesa
      DRVOBJS = mesa/src/?*.o mesa/src/X/?*.o
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
diff -urN XFree86-4.0/xc/programs/Xserver/GL/mesa/src/X/xf86glx.c XFree86-4.0-lia/xc/programs/Xserver/GL/mesa/src/X/xf86glx.c
--- XFree86-4.0/xc/programs/Xserver/GL/mesa/src/X/xf86glx.c	Thu Aug 17 22:07:38 2000
+++ XFree86-4.0-lia/xc/programs/Xserver/GL/mesa/src/X/xf86glx.c	Tue Aug  8 22:52:59 2000
@@ -62,6 +62,9 @@
 #include <GL/internal/glcore.h>
 #endif
 
+/* Avoid cyclic dependency between libglx and libGLcore due
+   to this symbol and glDDXExtensionInfo.  --davidm 00/08/08 */
+__GLXcontext *__glXLastContext;
 
 /*
  * This structure is statically allocated in the __glXScreens[]
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
 
@@ -106,6 +106,7 @@
  * Debug Macros/Definitions
  */
 /* #define DEBUGPCI  2 */    /* Disable/enable trace in PCI code */
+#define ErrorF printf
 
 #if defined(DEBUGPCI)
 
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

