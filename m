From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Wed, 22 Aug 2001 17:42:27 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.9)
Message-Id: <marc-linux-ia64-105590698805097@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 22, 2001 at 12:00:44PM +0200, Andreas Schwab wrote:
> The new DRM code (CONFIG_DRM_NEW) does not compile:
> 
> In file included from gamma_drv.c:92:
> drm_memory.h: In function `gamma_ioremap':
> drm_memory.h:319: structure has no member named `agp'
> drm_memory.h:338: structure has no member named `agp'

Ouch, sorry about that.  Patch is appended.  David, please apply.

Chris


diff -X /cvs/excludes -urN linux-2.4.9-ia64-010820-pristine/drivers/char/drm/drm_memory.h linux-2.4.9-ia64-010820-dev/drivers/char/drm/drm_memory.h
--- linux-2.4.9-ia64-010820-pristine/drivers/char/drm/drm_memory.h	Tue Aug 21 11:22:58 2001
+++ linux-2.4.9-ia64-010820-dev/drivers/char/drm/drm_memory.h	Wed Aug 22 10:34:37 2001
@@ -309,6 +309,11 @@
 void *DRM(ioremap)(unsigned long offset, unsigned long size, drm_device_t *dev)
 {
 	void *pt;
+#if __REALLY_HAVE_AGP
+	drm_map_t *map = NULL;
+	drm_map_list_t *r_list;
+	struct list_head *list;
+#endif
 
 	if (!size) {
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
@@ -316,52 +321,51 @@
 		return NULL;
 	}
 
-	if(dev->agp->cant_use_aperture = 0) {
+#if __REALLY_HAVE_AGP
+	if(dev->agp->cant_use_aperture = 0)
 		goto standard_ioremap;
-	} else {
-		drm_map_t *map    = NULL;
-		drm_map_list_t  *r_list;
-		struct list_head *list, *head;
-
-		list_for_each(list, &dev->maplist->head) {
-			r_list = (drm_map_list_t *)list;
-			map = r_list->map;
-			if (!map) continue;
-			if (map->offset <= offset &&
-				(map->offset + map->size) >= (offset + size))
+
+	list_for_each(list, &dev->maplist->head) {
+		r_list = (drm_map_list_t *)list;
+		map = r_list->map;
+		if (!map) continue;
+		if (map->offset <= offset &&
+			(map->offset + map->size) >= (offset + size))
+			break;
+	}
+	
+	if(map && map->type = _DRM_AGP) {
+		struct drm_agp_mem *agpmem;
+
+		for(agpmem = dev->agp->memory; agpmem;
+					agpmem = agpmem->next) {
+			if(agpmem->bound <= offset &&
+			   (agpmem->bound + (agpmem->pages
+				<< PAGE_SHIFT)) >= (offset + size))
 				break;
 		}
-		
-		if(map && map->type = _DRM_AGP) {
-			struct drm_agp_mem *agpmem;
-
-			for(agpmem = dev->agp->memory; agpmem;
-						agpmem = agpmem->next) {
-				if(agpmem->bound <= offset &&
-				   (agpmem->bound + (agpmem->pages
-					<< PAGE_SHIFT)) >= (offset + size))
-					break;
-			}
-
-			if(agpmem = NULL)
-				goto standard_ioremap;
-
-			pt = agpmem->memory->vmptr + (offset - agpmem->bound);
-			goto ioremap_success;
-		} else {
-			goto standard_ioremap;
-		}
+
+		if(agpmem = NULL)
+			goto ioremap_failure;
+
+		pt = agpmem->memory->vmptr + (offset - agpmem->bound);
+		goto ioremap_success;
 	}
 
 standard_ioremap:
+#endif
 	if (!(pt = ioremap(offset, size))) {
+#if __REALLY_HAVE_AGP
+ioremap_failure:
+#endif
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
 		return NULL;
 	}
-
+#if __REALLY_HAVE_AGP
 ioremap_success:
+#endif
 	spin_lock(&DRM(mem_lock));
 	++DRM(mem_stats)[DRM_MEM_MAPPINGS].succeed_count;
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_allocated += size;
@@ -377,7 +381,11 @@
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
+#if __REALLY_HAVE_AGP
 	else if(dev->agp->cant_use_aperture = 0)
+#else
+	else
+#endif
 		iounmap(pt);
 
 	spin_lock(&DRM(mem_lock));
diff -X /cvs/excludes -urN linux-2.4.9-ia64-010820-pristine/drivers/char/drm/drm_vm.h linux-2.4.9-ia64-010820-dev/drivers/char/drm/drm_vm.h
--- linux-2.4.9-ia64-010820-pristine/drivers/char/drm/drm_vm.h	Tue Aug 21 11:22:58 2001
+++ linux-2.4.9-ia64-010820-dev/drivers/char/drm/drm_vm.h	Wed Aug 22 10:34:35 2001
@@ -67,11 +67,11 @@
 			    int write_access)
 #endif
 {
-#if (defined(__alpha__) || defined(__ia64__)) && __REALLY_HAVE_AGP
+#if __REALLY_HAVE_AGP
 	drm_file_t *priv  = vma->vm_file->private_data;
 	drm_device_t *dev = priv->dev;
 	drm_map_t *map    = NULL;
-	drm_map_list_t  *r_list;
+	drm_map_list_t   *r_list;
 	struct list_head *list;
 
 	/*
@@ -122,12 +122,11 @@
 		 * There isn't a convenient way to call agp_bridge.unmask_
 		 * memory from here, so hard code it for now.
 		 */
-#if defined(__alpha__)
-		paddr = agpmem->memory->memory[offset] & ~1UL;
-#elif defined(__ia64__)
+#if defined(__ia64__)
 		paddr = (agpmem->memory->memory[offset] & 0xffffff) << 12;
+#else
+		paddr = agpmem->memory->memory[offset] & dev->agp->page_mask;
 #endif
-
 		page = virt_to_page(__va(paddr));
 		get_page(page);
 
@@ -515,20 +514,21 @@
 
 	switch (map->type) {
         case _DRM_AGP:
-#if defined(__alpha__) || defined(__ia64__)
-                /*
-                 * On Alpha and ia64 we can't talk to bus dma address from
-                 * the CPU, so for memory of type DRM_AGP, we'll deal with
-                 * sorting out the real physical pages and mappings
-                 * in nopage()
-                 */
-                vma->vm_ops = &DRM(vm_ops);
-
+#if __REALLY_HAVE_AGP
+		if(dev->agp->cant_use_aperture = 1) {
+                	/*
+                	 * On some systems we can't talk to bus dma address from
+                	 * the CPU, so for memory of type DRM_AGP, we'll deal
+                	 * with sorting out the real physical pages and mappings
+                	 * in nopage()
+                	 */
+                	vma->vm_ops = &DRM(vm_ops);
 #if defined(__ia64__)
-		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+			vma->vm_page_prot +				pgprot_writecombine(vma->vm_page_prot);
 #endif	
-
-                break;
+			goto mapswitch_out;
+		}
 #endif
                 /* fall through to _DRM_FRAME_BUFFER... */        
 	case _DRM_FRAME_BUFFER:
@@ -582,6 +582,9 @@
 	default:
 		return -EINVAL;	/* This should never happen. */
 	}
+#if __REALLY_HAVE_AGP
+mapswitch_out:
+#endif
 	vma->vm_flags |= VM_LOCKED | VM_SHM; /* Don't swap */
 
 #if LINUX_VERSION_CODE < 0x020203 /* KERNEL_VERSION(2,2,3) */

