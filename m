From: akpm@linux-foundation.org
Date: Wed, 21 Nov 2007 22:58:26 +0000
Subject: [patch 3/3] ia64 efi: make full use of macro efi_md_size
Message-Id: <200711212258.lALMwQTd013405@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Li Zefan <lizf@cn.fujitsu.com>

Macro efi_md_size is defined in efi.c, and here we apply it throughout
efi.c.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/efi.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -puN arch/ia64/kernel/efi.c~ia64-efi-make-full-use-of-macro-efi_md_size arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c~ia64-efi-make-full-use-of-macro-efi_md_size
+++ a/arch/ia64/kernel/efi.c
@@ -370,7 +370,7 @@ efi_get_pal_addr (void)
 			continue;
 		}
 
-		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
+		if (efi_md_size(md) > IA64_GRANULE_SIZE)
 			panic("Woah!  PAL code size bigger than a granule!");
 
 #if EFI_DEBUG
@@ -378,7 +378,7 @@ efi_get_pal_addr (void)
 
 		printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 			smp_processor_id(), md->phys_addr,
-			md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			md->phys_addr + efi_md_size(md),
 			vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
 		return __va(md->phys_addr);
@@ -523,7 +523,7 @@ efi_init (void)
 			md = p;
 			printk("mem%02u: type=%u, attr=0x%lx, range=[0x%016lx-0x%016lx) (%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			       md->phys_addr + efi_md_size(md),
 			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
@@ -656,7 +656,7 @@ efi_memory_descriptor (unsigned long phy
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < efi_md_size(md))
 			 return md;
 	}
 	return NULL;
@@ -1158,7 +1158,7 @@ efi_initialize_iomem_resources(struct re
 
 		res->name = name;
 		res->start = md->phys_addr;
-		res->end = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1;
+		res->end = md->phys_addr + efi_md_size(md) - 1;
 		res->flags = flags;
 
 		if (insert_resource(&iomem_resource, res) < 0)
_
