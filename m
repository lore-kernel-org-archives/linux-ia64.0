From: Robert Picco <Robert.Picco@hp.com>
Date: Wed, 05 May 2004 18:46:25 +0000
Subject: Re: [PATCH] boot parameters mem and max_addr
Message-Id: <40993681.7060108@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40991DE7.7010401@hp.com>
In-Reply-To: <40991DE7.7010401@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Whole patch again with documentation.

thanks,

Bob

diff -uNr -X /home/picco/losl/dontdiff linux-2.6.5-orig/arch/ia64/kernel/efi.c linux-2.6.5-mem/arch/ia64/kernel/efi.c
--- linux-2.6.5-orig/arch/ia64/kernel/efi.c	2004-04-03 22:36:15.000000000 -0500
+++ linux-2.6.5-mem/arch/ia64/kernel/efi.c	2004-05-04 11:56:42.000000000 -0400
@@ -53,7 +53,7 @@
 EXPORT_SYMBOL(efi_dir);
 #endif
 
-static unsigned long mem_limit = ~0UL;
+static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
@@ -304,6 +304,7 @@
 	void *efi_map_start, *efi_map_end, *p, *q;
 	efi_memory_desc_t *md, *check_md;
 	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;
+	unsigned long total_mem = 0;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -345,12 +346,18 @@
 			trim_top(md, last_granule_addr);
 
 		if (is_available_memory(md)) {
-			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
-				if (md->phys_addr > mem_limit)
+			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > max_addr) {
+				if (md->phys_addr > max_addr)
 					continue;
-				md->num_pages = (mem_limit - md->phys_addr) >> EFI_PAGE_SHIFT;
+				md->num_pages = (max_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
 			}
 
+			if (total_mem >= mem_limit)
+				continue;
+			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
+			if (total_mem > mem_limit)
+				md->num_pages -= ((total_mem - mem_limit) >> EFI_PAGE_SHIFT);
+
 			if (md->num_pages = 0)
 				continue;
 
@@ -484,7 +491,13 @@
 	for (cp = saved_command_line; *cp; ) {
 		if (memcmp(cp, "mem=", 4) = 0) {
 			cp += 4;
-			mem_limit = memparse(cp, &end) - 1;
+			mem_limit = memparse(cp, &end) - 2;
+			if (end != cp)
+				break;
+			cp = end;
+		} else if (memcmp(cp, "max_addr=", 9) = 0) {
+			cp += 9;
+			max_addr = memparse(cp, &end) - 1;
 			if (end != cp)
 				break;
 			cp = end;
@@ -495,8 +508,8 @@
 				++cp;
 		}
 	}
-	if (mem_limit != ~0UL)
-		printk(KERN_INFO "Ignoring memory above %luMB\n", mem_limit >> 20);
+	if (max_addr != ~0UL)
+		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
 
 	efi.systab = __va(ia64_boot_param->efi_systab);
 
diff -uNr -X /home/picco/losl/dontdiff linux-2.6.5-orig/Documentation/kernel-parameters.txt linux-2.6.5-mem/Documentation/kernel-parameters.txt
--- linux-2.6.5-orig/Documentation/kernel-parameters.txt	2004-04-03 22:38:27.000000000 -0500
+++ linux-2.6.5-mem/Documentation/kernel-parameters.txt	2004-05-05 13:47:49.000000000 -0400
@@ -574,6 +574,9 @@
 
 	maui=		[HW,OSS]
 			Format: <io>,<irq>
+
+	max_addr=	[KNL,BOOT,IA64] Force the kernel to consider this the maximum physical
+			address.
  
 	max_loop=       [LOOP] Maximum number of loopback devices that can
 			be mounted






