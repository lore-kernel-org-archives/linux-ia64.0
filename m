From: "Sourav Sen" <souravs@india.hp.com>
Date: Thu, 06 May 2004 09:30:32 +0000
Subject: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <003901c4334b$1a8a6de0$39624c0f@india.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Resending it as the last one line wrapped :-(

----------------------------------------------------
Hi,

The following simple patch creates a read-only file 
"memmap" under <mount point>/firmware/efi/ in sysfs 
and exposes the efi memory map thru it.
 
Thanks
Sourav
HP-STS, Bangalore

The patch is w.r.t 2.6.6-rc3
----------------------------
=====================================--- a/drivers/firmware/efivars.c        2004-05-05 13:55:40.000000000 +0530
+++ b/drivers/firmware/efivars.c        2004-05-06 14:03:13.000000000 +0530
@@ -580,10 +580,42 @@ systab_read(struct subsystem *entry, cha
        return str - buf;
 }

+/*
+ * Expose the efi memory map as kernel keeps it. Note, it may be a little
+ * different from what gets actually passed in at loader handoff time as a
+ * call to efi_memmap_walk modifies that.
+ */
+
+static ssize_t
+efi_memmap_read(struct subsystem *entry, char * buf)
+{
+       void * efi_map_start, *efi_map_end, *p;
+       efi_memory_desc_t *md;
+       u64 efi_desc_size;
+       char * str = buf;
+
+       if (!entry || !buf)
+               return -EINVAL;
+
+       efi_map_start = __va(ia64_boot_param->efi_memmap);
+       efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+       efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+       for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+               md = (efi_memory_desc_t *)p;
+               str += sprintf(str, "%2u  %-#18lx  %#016lx %#016lx\n", \
+                       md->type, md->attribute, md->phys_addr, \
+                       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT));
+       }
+       return (str - buf);
+}
+
 static EFI_ATTR(systab, 0400, systab_read, NULL);
+static EFI_ATTR(memmap, 0400, efi_memmap_read, NULL);

 static struct subsys_attribute *efi_subsys_attrs[] = {
        &efi_attr_systab,
+       &efi_attr_memmap,       /* Here comes one */
        NULL,   /* maybe more in the future? */
 }; 
