From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Fri, 02 Aug 2013 16:56:22 +0000
Subject: [PATCH v2 5/5] efi: x86: make efi_lookup_mapped_addr() a common function
Message-Id: <1375462582-16423-6-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org, Leif Lindholm <leif.lindholm@linaro.org>

efi_lookup_mapped_addr() is a handy utility for other platforms than
x86. Move it from arch/x86 to drivers/firmware. Add memmap pointer
to global efi structure, and initialise it on x86.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
---
 arch/x86/platform/efi/efi.c |   30 ++----------------------------
 drivers/firmware/efi/efi.c  |   32 ++++++++++++++++++++++++++++++++
 include/linux/efi.h         |    1 +
 3 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index ed2be58..fbc1d70 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -393,6 +393,8 @@ int __init efi_memblock_x86_reserve_range(void)
 
 	memblock_reserve(pmap, memmap.nr_map * memmap.desc_size);
 
+	efi.memmap = &memmap;
+
 	return 0;
 }
 
@@ -736,34 +738,6 @@ static void __init runtime_code_page_mkexec(void)
 	}
 }
 
-/*
- * We can't ioremap data in EFI boot services RAM, because we've already mapped
- * it as RAM.  So, look it up in the existing EFI memory map instead.  Only
- * callable after efi_enter_virtual_mode and before efi_free_boot_services.
- */
-void __iomem *efi_lookup_mapped_addr(u64 phys_addr)
-{
-	void *p;
-	if (WARN_ON(!memmap.map))
-		return NULL;
-	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
-		efi_memory_desc_t *md = p;
-		u64 size = md->num_pages << EFI_PAGE_SHIFT;
-		u64 end = md->phys_addr + size;
-		if (!(md->attribute & EFI_MEMORY_RUNTIME) &&
-		    md->type != EFI_BOOT_SERVICES_CODE &&
-		    md->type != EFI_BOOT_SERVICES_DATA)
-			continue;
-		if (!md->virt_addr)
-			continue;
-		if (phys_addr >= md->phys_addr && phys_addr < end) {
-			phys_addr += md->virt_addr - md->phys_addr;
-			return (__force void __iomem *)(unsigned long)phys_addr;
-		}
-	}
-	return NULL;
-}
-
 void efi_memory_uc(u64 addr, unsigned long size)
 {
 	unsigned long page_shift = 1UL << EFI_PAGE_SHIFT;
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4fa944a..afdd1c0 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -148,6 +148,38 @@ err_put:
 subsys_initcall(efisubsys_init);
 
 
+/*
+ * We can't ioremap data in EFI boot services RAM, because we've already mapped
+ * it as RAM.  So, look it up in the existing EFI memory map instead.  Only
+ * callable after efi_enter_virtual_mode and before efi_free_boot_services.
+ */
+void __iomem *efi_lookup_mapped_addr(u64 phys_addr)
+{
+	struct efi_memory_map *map;
+	void *p;
+	map = efi.memmap;
+	if (!map)
+		return NULL;
+	if (WARN_ON(!map->map))
+		return NULL;
+	for (p = map->map; p < map->map_end; p += map->desc_size) {
+		efi_memory_desc_t *md = p;
+		u64 size = md->num_pages << EFI_PAGE_SHIFT;
+		u64 end = md->phys_addr + size;
+		if (!(md->attribute & EFI_MEMORY_RUNTIME) &&
+		    md->type != EFI_BOOT_SERVICES_CODE &&
+		    md->type != EFI_BOOT_SERVICES_DATA)
+			continue;
+		if (!md->virt_addr)
+			continue;
+		if (phys_addr >= md->phys_addr && phys_addr < end) {
+			phys_addr += md->virt_addr - md->phys_addr;
+			return (__force void __iomem *)(unsigned long)phys_addr;
+		}
+	}
+	return NULL;
+}
+
 static __initdata efi_config_table_type_t common_tables[] = {
 	{ACPI_20_TABLE_GUID, "ACPI 2.0", &efi.acpi20},
 	{ACPI_TABLE_GUID, "ACPI", &efi.acpi},
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 09d9e42..c084b6d 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -558,6 +558,7 @@ extern struct efi {
 	efi_get_next_high_mono_count_t *get_next_high_mono_count;
 	efi_reset_system_t *reset_system;
 	efi_set_virtual_address_map_t *set_virtual_address_map;
+	struct efi_memory_map *memmap;
 } efi;
 
 static inline int
-- 
1.7.10.4

