From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 10 Apr 2002 16:28:29 +0000
Subject: [Linux-ia64] [PATCH] Legacy VGA fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_HR1DFHQCRA4Y2LGI4FII"
Message-Id: <marc-linux-ia64-105590701905426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_HR1DFHQCRA4Y2LGI4FII
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

This patch against 2.4.18+ia64-020226 removes a legacy VGA
dependency.  Non-legacy systems may have system memory
at 0xA0000, and if that's the case, we don't want to install the
VGA console.

Restructured conswitchp init slightly so that if both
CONFIG_DUMMY_CONSOLE and CONFIG_VGA_CONSOLE
are defined, conswitchp is always set to something, even if we
don't find VGA at 0xA0000.

This work is due to Alex Williamson (alex_williamson@hp.com).
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard
--------------Boundary-00=_HR1DFHQCRA4Y2LGI4FII
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="legacy_vga"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="legacy_vga"

diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/efi.c linux-2.4.18-ia64-020226-efi/arch/ia64/kernel/efi.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/efi.c	Fri Nov  9 15:26:17 2001
+++ linux-2.4.18-ia64-020226-efi/arch/ia64/kernel/efi.c	Wed Apr 10 10:07:04 2002
@@ -155,10 +155,10 @@
 		      case EFI_CONVENTIONAL_MEMORY:
 			if (!(md->attribute & EFI_MEMORY_WB))
 				continue;
-			if (md->phys_addr + (md->num_pages << 12) > mem_limit) {
+			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
 				if (md->phys_addr > mem_limit)
 					continue;
-				md->num_pages = (mem_limit - md->phys_addr) >> 12;
+				md->num_pages = (mem_limit - md->phys_addr) >> EFI_PAGE_SHIFT;
 			}
 			if (md->num_pages == 0) {
 				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
@@ -167,7 +167,7 @@
 			}
 
 			curr.start = PAGE_OFFSET + md->phys_addr;
-			curr.end   = curr.start + (md->num_pages << 12);
+			curr.end   = curr.start + (md->num_pages << EFI_PAGE_SHIFT);
 
 			if (!prev_valid) {
 				prev = curr;
@@ -254,12 +254,12 @@
 			continue;
 		}
 
-		if (md->num_pages << 12 > IA64_GRANULE_SIZE)
+		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
 			panic("Woah!  PAL code size bigger than a granule!");
 
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 		printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
-		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages << 12),
+		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
 		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 
 		/*
@@ -375,7 +375,7 @@
 			md = p;
 			printk("mem%02u: type=%u, attr=0x%lx, range=[0x%016lx-0x%016lx) (%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages<<12) - 1, md->num_pages >> 8);
+			       md->phys_addr + (md->num_pages<<EFI_PAGE_SHIFT) - 1, md->num_pages >> 8);
 		}
 	}
 #endif
@@ -478,6 +478,26 @@
 			if (md->attribute == (EFI_MEMORY_UC | EFI_MEMORY_RUNTIME))
 				return md->phys_addr;
 		}
+	}
+	return 0;
+}
+
+u32
+efi_mem_type (u64 phys_addr)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if ((md->phys_addr <= phys_addr) && (phys_addr <=
+		    (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1)))
+			 return md->type;
 	}
 	return 0;
 }
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/setup.c linux-2.4.18-ia64-020226-efi/arch/ia64/kernel/setup.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/setup.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-efi/arch/ia64/kernel/setup.c	Tue Apr  9 21:43:17 2002
@@ -349,10 +349,18 @@
 	}
 
 #ifdef CONFIG_VT
-# if defined(CONFIG_VGA_CONSOLE)
-	conswitchp = &vga_con;
-# elif defined(CONFIG_DUMMY_CONSOLE)
+# if defined(CONFIG_DUMMY_CONSOLE)
 	conswitchp = &dummy_con;
+# endif
+# if defined(CONFIG_VGA_CONSOLE)
+	/*
+	 * Non-legacy systems may route legacy VGA MMIO range to system
+	 * memory.  vga_con probes the MMIO hole, so memory looks like
+	 * a VGA device to it.  The EFI memory map can tell us if it's
+	 * memory so we can avoid this problem.
+	 */
+	if (efi_mem_type(0xA0000) != EFI_CONVENTIONAL_MEMORY)
+		conswitchp = &vga_con;
 # endif
 #endif
 
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/asm-ia64/efi.h linux-2.4.18-ia64-020226-efi/include/asm-ia64/efi.h
--- linux-2.4.18-ia64-020226-orig/include/asm-ia64/efi.h	Fri Apr  5 16:49:20 2002
+++ linux-2.4.18-ia64-020226-efi/include/asm-ia64/efi.h	Wed Apr 10 09:23:33 2002
@@ -82,6 +82,8 @@
 #define EFI_MEMORY_RUNTIME	0x8000000000000000	/* range requires runtime mapping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
 
+#define EFI_PAGE_SHIFT		12
+
 typedef struct {
 	u32 type;
 	u32 pad;
@@ -239,6 +241,7 @@
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, if possible */
 extern u64  efi_get_iobase (void);
+extern u32  efi_mem_type (u64 phys_addr);
 
 /*
  * Variable Attributes

--------------Boundary-00=_HR1DFHQCRA4Y2LGI4FII--

