From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 17 Apr 2004 04:25:07 +0000
Subject: Re: heads up: 2.6.5 triggers Nvidia binary-only driver bug
Message-Id: <16512.45475.135384.874746@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16509.34085.831565.155412@napali.hpl.hp.com>
In-Reply-To: <16509.34085.831565.155412@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 Apr 2004 11:38:29 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> It turns out the attached patch triggers a latent bug in the
  David> Nvidia binary-only driver.  The quick workaround is to
  David> comment out the line "MAX_DMA_ADDRESS = ~0UL" in sba_setup().
  David> The problem appears to be that the Nvidia driver is
  David> incorrectly assuming that allocating with GFP_DMA will give
  David> addresses below 4GB.

  David> I believe it's possible to fix this properly in the Nvidia
  David> driver (without touching the binary-only portion of the
  David> driver, I mean).  If someone is eager to investigate, please
  David> let me know so I can take it off of my list of things to
  David> worry about.

The patch below seems to fix the problem.  At least I was able to
restart the X server with the Nvidia driver about 10 times without any
problem.

The patch could do some more cleanup so that the same thing is done on
all platforms, but I believe the DMA-mapping stuff is actively being
worked on by Nvidia, so I just went for the quick fix for now.

	--david

diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile	2004-01-28 21:07:02.000000000 -0800
@@ -73,7 +73,7 @@
 #
 
 EXTRA_CFLAGS += -I$(src)
-EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
+EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O2 -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
 
 #
 # We rely on these two definitions below; if they aren't set, we set them to
diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild	2004-01-28 21:07:02.000000000 -0800
@@ -73,7 +73,7 @@
 #
 
 EXTRA_CFLAGS += -I$(src)
-EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
+EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O2 -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
 
 #
 # We rely on these two definitions below; if they aren't set, we set them to
diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h	2004-04-16 20:47:03.004251195 -0700
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
diff -urN NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv.c NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv.c
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv.c	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv.c	2004-04-16 20:53:11.224454354 -0700
@@ -403,7 +403,8 @@
 
         page_ptr->phys_addr = phys_addr;
         page_ptr->virt_addr = virt_addr;
-        page_ptr->dma_addr = page_ptr->phys_addr;
+        page_ptr->dma_addr = pci_map_single(at->dev, (void *) virt_addr, PAGE_SIZE,
+					    PCI_DMA_BIDIRECTIONAL);
 
         NV_SET_PAGE_ATTRIB_UNCACHED(page_ptr);
 
@@ -447,6 +448,8 @@
         {
             ClearPageReserved(NV_GET_PAGE_STRUCT(page_ptr->phys_addr));
             NV_SET_PAGE_ATTRIB_CACHED(page_ptr);
+	    pci_unmap_single(at->dev, page_ptr->dma_addr, PAGE_SIZE,
+			     PCI_DMA_BIDIRECTIONAL);
 #if defined(NVCPU_X86_64)
             // only unmap the page if it really was mapped through
             // the iommu (although pci_unmap_single is safe anyways)
@@ -502,9 +505,7 @@
     while (pages_left)
     {
         NV_SET_PAGE_ATTRIB_CACHED(page_ptr);
-#if defined(NVCPU_X86_64)
         pci_unmap_single(at->dev, page_ptr->dma_addr, PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
-#endif
         NV_FREE_PAGES(page_ptr->virt_addr, 0);
         page_ptr++;
         pages_left--;
@@ -2510,7 +2511,9 @@
                 unsigned long addr = (unsigned long) *pAddress;
                 at->page_table[i].virt_addr = addr + (i * PAGE_SIZE);
                 at->page_table[i].phys_addr = nv_get_kern_phys_address((addr + (i * PAGE_SIZE)));
-                at->page_table[i].dma_addr = at->page_table[i].phys_addr;
+                at->page_table[i].dma_addr = pci_map_single(at->dev,
+							    (char *) addr + (i * PAGE_SIZE),
+							    PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
             }
 
             at->flags = NV_ALLOC_TYPE_PCI | NV_ALLOC_TYPE_KERNEL | NV_ALLOC_TYPE_VMALLOC;
@@ -2540,7 +2543,9 @@
                 unsigned long addr = (unsigned long) *pAddress;
                 at->page_table[i].virt_addr = addr + (i * PAGE_SIZE);
                 at->page_table[i].phys_addr = __pa((addr + (i * PAGE_SIZE)));
-                at->page_table[i].dma_addr = at->page_table[i].phys_addr;
+                at->page_table[i].dma_addr = pci_map_single(at->dev,
+							    (char *) addr + (i * PAGE_SIZE),
+							    PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
             }
 
             at->flags = NV_ALLOC_TYPE_PCI | NV_ALLOC_TYPE_CONTIG;
