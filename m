From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 01 Apr 2005 00:31:36 +0000
Subject: patch to enable Nvidia v5336 on v2.6.12 kernel
Message-Id: <200504010031.j310VawS024431@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a patch to make the v5336 Nvidia binary-only driver work with
the v2.6.12 kernel.  The major change is that most AGP functions now
take an explicit agp_bridge argument.  Fortunately, the AGP code
initializes this by default to the one (and only) bridge that most
systems have, so this isn't a terribly deep thing.  Also, I got rid of
all the inter_module gunk since it just caused lots of output which
obscured real warnings.

Note that on zx1-based systems, you need to patch the AGP code
as described in this mail:

  http://www.gelato.unsw.edu.au/linux-ia64/0503/13676.html

Otherwise, the AGP code will crash trying to read from a
(non-existent) PCI device.

	--david

diff -urN -x nv_compiler.h -x '*.mod.c' -x '*.ko' -x '*.d' -x '*.o' -x '*~' -x build -x Makefile -x '.*' NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/Makefile.kbuild	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/Makefile.kbuild	2005-01-24 15:49:37.000000000 -0800
@@ -73,7 +73,7 @@
 #
 
 EXTRA_CFLAGS += -I$(src)
-EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wpointer-arith  -Wno-multichar  -Werror -O -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
+EXTRA_CFLAGS += -Wall -Wimplicit -Wreturn-type -Wswitch -Wformat -Wchar-subscripts -Wparentheses -Wno-multichar  -Werror -O2 -MD $(DEFINES) $(INCLUDES) -Wno-cast-qual -Wno-error
 
 #
 # We rely on these two definitions below; if they aren't set, we set them to
diff -urN -x nv_compiler.h -x '*.mod.c' -x '*.ko' -x '*.d' -x '*.o' -x '*~' -x build -x Makefile -x '.*' NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv-linux.h	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv-linux.h	2005-03-31 15:23:32.000000000 -0800
@@ -24,7 +24,7 @@
 #  define KERNEL_2_4
 #elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 0)
 #  error This driver does not support 2.5 kernels!
-#elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 7, 0) && defined(NVCPU_X86)
+#elif LINUX_VERSION_CODE < KERNEL_VERSION(2, 7, 0)
 #  define KERNEL_2_6
 #else
 #  error This driver does not support development kernels!
@@ -293,13 +293,13 @@
 #if defined(NVCPU_IA64)
 #define NV_VMALLOC(ptr, size) \
     { \
-        (void *) (ptr) = vmalloc_dma(size); \
+        (ptr) = __vmalloc(size, GFP_KERNEL|GFP_DMA, PAGE_KERNEL); \
         VM_ALLOC_RECORD(ptr, size, "vm_alloc"); \
     }
 #else
 #define NV_VMALLOC(ptr, size) \
     { \
-        (void *) (ptr) = vmalloc_32(size); \
+        (ptr) = vmalloc_32(size); \
         VM_ALLOC_RECORD(ptr, size, "vm_alloc"); \
     }
 #endif
@@ -333,13 +333,13 @@
  */
 #define NV_KMALLOC(ptr, size) \
     { \
-        (void *) (ptr) = kmalloc(size, GFP_KERNEL); \
+        (ptr) = kmalloc(size, GFP_KERNEL); \
         KM_ALLOC_RECORD(ptr, size, "km_alloc"); \
     }
 
 #define NV_KMALLOC_ATOMIC(ptr, size) \
     { \
-        (void *) (ptr) = kmalloc(size, GFP_ATOMIC); \
+        (ptr) = kmalloc(size, GFP_ATOMIC); \
         KM_ALLOC_RECORD(ptr, size, "km_alloc_atomic"); \
     }  
 
@@ -352,7 +352,7 @@
 
 #define NV_GET_FREE_PAGES(ptr, order) \
     { \
-        (void *) (ptr) = __get_free_pages(NV_GFP_HW, order); \
+        (ptr) = __get_free_pages(NV_GFP_HW, order); \
     }
         
 #define NV_FREE_PAGES(ptr, order) \
@@ -386,9 +386,6 @@
 #endif
 
 /* common defines */
-#define GET_MODULE_SYMBOL(mod,sym)    (const void *) inter_module_get(sym)
-#define PUT_MODULE_SYMBOL(sym)        inter_module_put((char *) sym)
-
 #define NV_GET_PAGE_STRUCT(phys_page) virt_to_page(__va(phys_page))
 #define NV_VMA_OFFSET(vma)            (((vma)->vm_pgoff) << PAGE_SHIFT)
 #define NV_VMA_PRIVATE(vma)           ((vma)->vm_private_data)
@@ -454,14 +451,22 @@
  * relevant releases to date use it. This version was backported to 2.4 
  * without means to identify the change, hence this hack.
  */
-#if defined(REMAP_PAGE_RANGE_5)
-#define NV_REMAP_PAGE_RANGE(a, b...)    remap_page_range(vma, a, ## b)
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 11)
+#define NV_REMAP_PFN_RANGE(a,b,c,d)	remap_pfn_range(vma, a, b, c, d)
+#elif defined(REMAP_PAGE_RANGE_5)
+#define NV_REMAP_PFN_RANGE(a, b...)    remap_page_range(vma, a << PAGE_SHIFT, ## b)
 #elif defined(REMAP_PAGE_RANGE_4)
-#define NV_REMAP_PAGE_RANGE(a, b...)    remap_page_range(a, ## b)
+#define NV_REMAP_PFN_RANGE(a, b...)    remap_page_range(a << PAGE_SHIFT, ## b)
 #else
 #error "Couldn't determine number of arguments expected by remap_page_range!"
 #endif
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 11)
+typedef pgd_t pud_t;
+# define pud_offset(pg_dir, address)	(pg_dir);
+# define pud_none(pud)			0
+#endif
+
 #if defined(pte_offset_atomic)
 #define NV_PTE_OFFSET(addres, pg_mid_dir, pte) \
     { \
@@ -540,17 +545,6 @@
 #define page_to_pfn(page)  ((page) - mem_map)
 #endif
 
-/* On IA64 physical memory is partitioned into a cached and an
- * uncached view controlled by bit 63.  Set this bit when remapping
- * page ranges.  
- */
-#if defined(NVCPU_IA64)
-#define phys_to_uncached(addr) ((addr) | ((unsigned long) 1<<63))
-#else
-/* Some other scheme must be used on this platform */
-#define phys_to_uncached(addr) (addr)
-#endif
-
 /*
  * An allocated bit of memory using NV_MEMORY_ALLOCATION_OFFSET
  *   looks like this in the driver
diff -urN -x nv_compiler.h -x '*.mod.c' -x '*.ko' -x '*.d' -x '*.o' -x '*~' -x build -x Makefile -x '.*' NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv.c NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv.c
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/nv.c	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/nv.c	2005-03-31 15:23:20.000000000 -0800
@@ -212,12 +212,15 @@
     count = 0;
     dev = (struct pci_dev *) 0;
 
-    dev = pci_find_class(PCI_CLASS_DISPLAY_VGA << 8, dev);
+    dev = pci_get_class(PCI_CLASS_DISPLAY_VGA << 8, dev);
     while (dev)
     {
         if ((dev->vendor != 0x10de) || (dev->device < 0x20))
             goto next;
 
+	if (pci_enable_device(dev))
+		goto next;
+
         /* initialize bus-dependent config state */
         nvl = &nv_linux_devices[count];
         nv  = NV_STATE_PTR(nvl);
@@ -303,7 +306,7 @@
         }
 
     next:
-        dev = pci_find_class(PCI_CLASS_DISPLAY_VGA << 8, dev);
+        dev = pci_get_class(PCI_CLASS_DISPLAY_VGA << 8, dev);
     }
 
     nv_printf(NV_DBG_INFO, "NVRM: found %d device%s\n", count, count ? "" : "s");
@@ -620,7 +623,7 @@
     u8     cap_ptr;
     int    func, slot;
 
-    dev = pci_find_class(class << 8, NULL);
+    dev = pci_get_class(class << 8, NULL);
     do {
         for (func = 0; func < 8; func++) {
             slot = PCI_SLOT(dev->devfn);
@@ -631,7 +634,7 @@
             if (cap_ptr)
                 return fn;
         }
-        dev = pci_find_class(class << 8, dev);
+        dev = pci_get_class(class << 8, dev);
     } while (dev);
 
     return NULL;
@@ -907,10 +910,6 @@
     /* create /proc/driver/nvidia */
     nvos_proc_create();
 
-#if defined(DEBUG)
-    inter_module_register("nv_linux_devices", THIS_MODULE, nv_linux_devices);
-#endif
-
     return 0;
 
  failed:
@@ -932,10 +931,6 @@
 
     nv_printf(NV_DBG_INFO, "nvidia_exit_module\n");
 
-#if defined(DEBUG)
-    inter_module_unregister("nv_linux_devices");
-#endif
-
 #ifdef CONFIG_PM
     do
     {
@@ -1070,7 +1065,7 @@
  * addresses by the CPU.  This nopage handler will fault on CPU
  * accesses to AGP memory and map the address to the correct page.
  */
-struct page *nv_kern_vma_nopage(struct vm_area_struct *vma, unsigned long address, int write_access)
+struct page *nv_kern_vma_nopage(struct vm_area_struct *vma, unsigned long address, int *write_accessp)
 {
 #if defined(NVCPU_IA64) && (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 4, 9))
     nv_alloc_t *at, *tmp;
@@ -1201,6 +1196,7 @@
 {
     nv_state_t *nv = (nv_state_t *) 0;
     nv_linux_state_t *nvl = (nv_linux_state_t *) 0;
+    nv_file_private_t *nv_private;
     int devnum;
     int rc = 0, status;
 
@@ -1229,7 +1225,8 @@
     nv_printf(NV_DBG_INFO, "nv_kern_open on device %d\n", devnum);
     nv_down(nvl->ldata_lock);
 
-    NVL_FROM_FILEP(file) = nvl;
+    nv_private = file->private_data;
+    nv_private->nvptr = nvl;
 
     /*
      * map the memory and allocate isr on first open
@@ -1405,8 +1402,8 @@
             pages = nv->regs->size / PAGE_SIZE;
 
         vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-        if (NV_REMAP_PAGE_RANGE(vma->vm_start,
-                             phys_to_uncached(NV_VMA_OFFSET(vma)),
+        if (NV_REMAP_PFN_RANGE(vma->vm_start,
+                             NV_VMA_OFFSET(vma) >> PAGE_SHIFT,
                              vma->vm_end - vma->vm_start,
                              vma->vm_page_prot))
             return -EAGAIN;
@@ -1424,8 +1421,8 @@
             pages = nv->fb->size / PAGE_SIZE;
 
         vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-        if (NV_REMAP_PAGE_RANGE(vma->vm_start,
-                             phys_to_uncached(NV_VMA_OFFSET(vma)),
+        if (NV_REMAP_PFN_RANGE(vma->vm_start,
+                             NV_VMA_OFFSET(vma) >> PAGE_SHIFT,
                              vma->vm_end - vma->vm_start,
                              vma->vm_page_prot))
             return -EAGAIN;
@@ -1512,7 +1509,8 @@
         while (pages--)
         {
             page = (unsigned long) at->page_table[i++].phys_addr;
-            if (NV_REMAP_PAGE_RANGE(start, page, PAGE_SIZE, PAGE_SHARED))
+            if (NV_REMAP_PFN_RANGE(start, page >> PAGE_SHIFT, PAGE_SIZE,
+				   PAGE_SHARED))
                 return -EAGAIN;
             start += PAGE_SIZE;
             pos += PAGE_SIZE;
@@ -1863,6 +1861,7 @@
     struct file *file
 )
 {
+    nv_file_private_t *nv_private;
     nv_state_t *nv;
     nv_linux_state_t *nvl;
     int rc = 0;
@@ -1877,7 +1876,8 @@
     nv->device_number = NV_CONTROL_DEVICE_NUMBER;
 
     /* save the nv away in file->private_data */
-    NVL_FROM_FILEP(file) = nvl;
+    nv_private = file->private_data;
+    nv_private->nvptr = nvl;
 
     if (nv->usage_count = 0)
     {
@@ -2308,6 +2308,7 @@
 )
 {
     pgd_t *pg_dir;
+    pud_t *pud_dir;
     pmd_t *pg_mid_dir;
     pte_t pte;
     unsigned long retval;
@@ -2318,7 +2319,11 @@
     if (pgd_none(*pg_dir))
         goto failed;
 
-    pg_mid_dir = pmd_offset(pg_dir, address);
+    pud_dir = pud_offset(pg_dir, address);
+    if (pud_none(*pud_dir))
+	    goto failed;
+
+    pg_mid_dir = pmd_offset(pud_dir, address);
     if (pmd_none(*pg_mid_dir))
         goto failed;
 
@@ -2862,27 +2867,6 @@
             return status;
     }
 
-    /* we're either explicitly not using agpgart,
-     * or trying to use agpgart failed
-     * make sure the user did not specify "use agpgart only"
-     */
-    if ( (NV_AGP_DISABLED(nv)) && (config & NVOS_AGP_CONFIG_NVAGP) )
-    {
-        /* make sure the user does not have agpgart loaded */
-        if (inter_module_get("drm_agp")) {
-            inter_module_put("drm_agp");
-            nv_printf(NV_DBG_WARNINGS, "NVRM: not using NVAGP, AGPGART is loaded!!\n");
-        } else {
-#if defined(CONFIG_X86_64) && defined(CONFIG_GART_IOMMU)
-            nv_printf(NV_DBG_WARNINGS, "NVRM: not using NVAGP, kernel was compiled with GART_IOMMU support!!\n");
-#else
-            status = rm_init_agp(nv);
-            if (status = RM_OK)
-                nv->agp_config = NVOS_AGP_CONFIG_NVAGP;
-#endif
-        }
-    }
-
     nv_printf(NV_DBG_SETUP, 
         "NVRM: agp_init finished with status 0x%x and config %d\n",
         status, nv->agp_config);
diff -urN -x nv_compiler.h -x '*.mod.c' -x '*.ko' -x '*.d' -x '*.o' -x '*~' -x build -x Makefile -x '.*' NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/os-agp.c NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/os-agp.c
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/os-agp.c	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/os-agp.c	2005-03-31 15:51:36.000000000 -0800
@@ -47,7 +47,6 @@
 
 agp_kern_info         agpinfo;
 agp_gart              gart;
-const drm_agp_t       *drm_agp_p;
 
 #if defined(CONFIG_MTRR)
 #define MTRR_DEL(gart) if ((gart).mtrr > 0) mtrr_del((gart).mtrr, 0, 0);
@@ -75,12 +74,7 @@
 
     memset( (void *) &gart, 0, sizeof(agp_gart));
 
-    if (!(drm_agp_p = inter_module_get_request("drm_agp", "agpgart")))
-    {
-        nv_printf(NV_DBG_ERRORS,
-            "NVRM: AGPGART: unable to retrieve symbol table\n");
-        return 1;
-    }
+    request_module("%s", "agpgart");
 
     /* NOTE: from here down, return an error code of '-1'
      * that indicates that agpgart is loaded, but we failed to use it
@@ -88,7 +82,7 @@
      * the memory controller.
      */
 
-    if (drm_agp_p->acquire())
+    if (!agp_bridge)
     {
         nv_printf(NV_DBG_ERRORS, "NVRM: AGPGART: backend in use\n");
         return -1;
@@ -113,11 +107,10 @@
      * chipsets via this function. If this Linux 2.4 kernels behaves the same
      * way, we have no way to know.
      */
-    drm_agp_p->copy_info(&agpinfo);
+    agp_copy_info(&agpinfo);
 #else
-    if (drm_agp_p->copy_info(&agpinfo)) {
-        drm_agp_p->release();
-        inter_module_put("drm_agp");
+    if (agp_copy_info(agp_bridge, &agpinfo)) {
+        agp_backend_release(agp_bridge);
         return -1;
     }
 #endif    
@@ -134,8 +127,7 @@
          */
         nv_printf(NV_DBG_ERRORS, 
             "NVRM: AGPGART: unable to set MTRR write-combining\n");
-        drm_agp_p->release();
-        inter_module_put("drm_agp");
+        agp_backend_release(agp_bridge);
         return -1;
     }
 #endif
@@ -151,8 +143,7 @@
     {
         nv_printf(NV_DBG_ERRORS, "NVRM: AGPGART: unable to remap aperture\n");
         MTRR_DEL(gart);
-        drm_agp_p->release();
-        inter_module_put("drm_agp");
+        agp_backend_release(agp_bridge);
         return -1;
     }
 
@@ -163,8 +154,7 @@
         nv_printf(NV_DBG_ERRORS, "NVRM: AGPGART: unable to allocate bitmap\n");
         NV_IOUNMAP(gart.aperture, RM_PAGE_SIZE);
         MTRR_DEL(gart);
-        drm_agp_p->release();
-        inter_module_put("drm_agp");
+        agp_backend_release(agp_bridge);
         return -1;
     }
 
@@ -175,8 +165,7 @@
         os_free_mem(bitmap);
         NV_IOUNMAP(gart.aperture, RM_PAGE_SIZE);
         MTRR_DEL(gart);
-        drm_agp_p->release();
-        inter_module_put("drm_agp");
+        agp_backend_release(agp_bridge);
         return -1;
     }
 
@@ -186,7 +175,7 @@
     if (!(agp_rate & 0x00000004)) agpinfo.mode &= ~0x00000004;
     if (!(agp_rate & 0x00000002)) agpinfo.mode &= ~0x00000002;
     
-    drm_agp_p->enable(agpinfo.mode);
+    agp_enable(agp_bridge, agpinfo.mode);
 
     *ap_phys_base   = (void*) agpinfo.aper_base;
     *ap_mapped_base = (void*) gart.aperture;
@@ -221,9 +210,7 @@
         NV_IOUNMAP(gart.aperture, RM_PAGE_SIZE);
     }
 
-    drm_agp_p->release();
-
-    inter_module_put("drm_agp");
+    agp_backend_release(agp_bridge);
 
     if (rm_clear_agp_bitmap(nv, &bitmap))
     {
@@ -270,7 +257,7 @@
         return RM_ERROR;
     }
 
-    ptr = drm_agp_p->allocate_memory(PageCount, AGP_NORMAL_MEMORY);
+    ptr = agp_allocate_memory(agp_bridge, PageCount, AGP_NORMAL_MEMORY);
     if (ptr = NULL)
     {
         *pAddress = (void*) 0;
@@ -278,7 +265,7 @@
         return RM_ERR_NO_FREE_MEM;
     }
     
-    err = drm_agp_p->bind_memory(ptr, *Offset);
+    err = agp_bind_memory(ptr, *Offset);
     if (err)
     {
         // this happens a lot when the aperture itself fills up..
@@ -295,7 +282,7 @@
     if (status != RM_OK)
     {
         nv_printf(NV_DBG_ERRORS, "NVRM: memory allocation failed\n");
-        drm_agp_p->unbind_memory(ptr);
+        agp_unbind_memory(ptr);
         goto fail;
     }
 
@@ -310,7 +297,7 @@
     return RM_OK;
 
 fail:
-    drm_agp_p->free_memory(ptr);
+    agp_free_memory(ptr);
     *pAddress = (void*) 0;
 
     return RM_ERROR;
@@ -350,7 +337,7 @@
     {
         nv_printf(NV_DBG_ERRORS, "NVRM: AGPGART: unable to remap %lu pages\n",
             (unsigned long)agp_data->num_pages);
-        drm_agp_p->unbind_memory(agp_data->ptr);
+        agp_unbind_memory(agp_data->ptr);
         goto fail;
     }
     
@@ -449,8 +436,8 @@
     {
         size_t pages = ptr->page_count;
 
-        drm_agp_p->unbind_memory(ptr);
-        drm_agp_p->free_memory(ptr);
+        agp_unbind_memory(ptr);
+        agp_free_memory(ptr);
 
         nv_printf(NV_DBG_INFO, "NVRM: AGPGART: freed %ld pages\n",
             (unsigned long)pages);
diff -urN -x nv_compiler.h -x '*.mod.c' -x '*.ko' -x '*.d' -x '*.o' -x '*~' -x build -x Makefile -x '.*' NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/os-interface.c NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/os-interface.c
--- NVIDIA-Linux-ia64-1.0-5336-pkg1/usr/src/nv/os-interface.c	2004-01-16 12:46:59.000000000 -0800
+++ NVIDIA-Linux-ia64-1.0-5336-pkg1-davidm/usr/src/nv/os-interface.c	2005-03-31 15:28:54.000000000 -0800
@@ -738,7 +738,9 @@
     struct wb_mem_t *next;
 } wb_mem;
 
+#ifdef CONFIG_MTRR
 static wb_mem *wb_list = NULL;
+#endif
 
 int save_wb(unsigned int start, unsigned int size)
 {
@@ -913,8 +915,8 @@
 
     vma = (struct vm_area_struct *) *priv;
 
-    if (NV_REMAP_PAGE_RANGE(vma->vm_start,
-                start & PAGE_MASK, size_bytes, PAGE_SHARED))
+    if (NV_REMAP_PFN_RANGE(vma->vm_start,
+			   start >> PAGE_SHIFT, size_bytes, PAGE_SHARED))
         return NULL;
 
     return (void *)(NV_UINTPTR_T) vma->vm_start;
