From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 22 Jul 2003 00:43:54 +0000
Subject: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105883467032028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On SN2 we have a 'fetchop' driver which does various magical things
with uncached memory (atomic operations within or across partitions).

To support this we have efi_memmap_walk_uc defined in a very similar
way to efi_memmap_walk.

How do people feel about merging this in the generic code (rather than
hiding it away in the driver or something more complex like
abstraction and changes to the current efi code)?

I'd also like to see a version of this in 2.5.x.


 arch/ia64/kernel/efi.c |   27 +++++++++++++++++++++++++++
 include/linux/efi.h    |    1 +
 2 files changed, 28 insertions(+)



Flame away,

  --cw


=== arch/ia64/kernel/efi.c 1.12 vs edited ==--- 1.12/arch/ia64/kernel/efi.c	Fri Mar 14 16:08:01 2003
+++ edited/arch/ia64/kernel/efi.c	Mon Jul 21 17:34:27 2003
@@ -723,3 +723,30 @@
  	remove_proc_entry(efi_dir->name, NULL);
 #endif
 }
+
+/*
+ * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
+ * has memory that marked as only EFI_MEMORY_UC.
+ */
+void
+efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size, start, end;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		if (md->attribute = EFI_MEMORY_UC) {
+			start = PAGE_ALIGN(md->phys_addr);
+			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
+			if ((*callback)(start, end, arg) < 0)
+				return;
+		}
+	}
+}
=== include/linux/efi.h 1.3 vs edited ==--- 1.3/include/linux/efi.h	Thu Sep 12 11:57:59 2002
+++ edited/include/linux/efi.h	Mon Jul 21 17:35:43 2003
@@ -260,6 +260,7 @@
 extern void efi_init (void);
 extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
+extern void efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, if possible */
 extern u64 efi_get_iobase (void);
