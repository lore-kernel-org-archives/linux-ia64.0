From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Mar 2004 05:20:52 +0000
Subject: small patch to enable Nvidia driver for Linux v2.6.x
Message-Id: <200403040520.i245Kqpn021979@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a small patch which allows to build the Nvidia 1.0-5336
driver to be built on ia64 for the 2.6 kernel.  To build the driver
for 2.6, do something along the lines of:

 - download NVIDIA-Linux-ia64-1.0-5336-pkg1.run
 # bash ./NVIDIA-Linux-ia64-1.0-5336-pkg1.run -x
 # cd NVIDIA-Linux-ia64-1.0-5336-pkg1
 # cat THISMAIL | patch -p1
 # make install

That should be it.

	--david

diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild	2004-01-28 21:07:02.660901536 -0800
@@ -73,7 +73,7 @@
 #
 
 EXTRA_CFLAGS += -I$(src)
-EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
+EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O2 -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
 
 #
 # We rely on these two definitions below; if they aren't set, we set them to
diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h	2004-01-28 20:55:00.049596599 -0800
@@ -24,7 +24,7 @@
 #  define KERNEL_2_4
 #elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 0)
 #  error This driver does not support 2.5 kernels!
-#elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 7, 0) && defined(NVCPU_X86)
+#elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 7, 0)
 #  define KERNEL_2_6
 #else
 #  error This driver does not support development kernels!
@@ -293,7 +293,7 @@
 #if defined(NVCPU_IA64)
 #define NV_VMALLOC(ptr, size) \
     { \
-        (void *) (ptr) = vmalloc_dma(size); \
+        (void *) (ptr) = __vmalloc(size, GFP_KERNEL|GFP_DMA, PAGE_KERNEL); \
         VM_ALLOC_RECORD(ptr, size, "vm_alloc"); \
     }
 #else
