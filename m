From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 07 Oct 2004 22:46:27 +0000
Subject: [PATCH] fix mem= & max_addr=
Message-Id: <1097189187.4491.63.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This should hopefully fix all strange behavior with using mem= or
max_addr= when trying to limit memory usage.  The current code has
several problems with splitting granules and removing the dangling
pieces on subsequent passes.  This potentially happened when mem_limit
hits total_mem and any time we reduced the page count of an entry
without updating first_non_wb_addr.  There was also an off by one in
max_addr that caused an extra granule to get dropped sometimes.

   With this change, there's some extra fuzz introduced that a max_addr
specification will get rounded down to a granule boundary and memory
quantity, when using mem=, will be within a granule size of the
requested amount.  Let me know if anyone finds more problems with it.
Thanks,

	Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/kernel/efi.c 1.36 vs edited ==--- 1.36/arch/ia64/kernel/efi.c	2004-08-25 11:50:37 -06:00
+++ edited/arch/ia64/kernel/efi.c	2004-10-07 15:59:50 -06:00
@@ -348,19 +348,31 @@
 			trim_top(md, last_granule_addr);
 
 		if (is_available_memory(md)) {
-			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > max_addr) {
-				if (md->phys_addr > max_addr)
+			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) >= max_addr) {
+				if (md->phys_addr >= max_addr)
 					continue;
 				md->num_pages = (max_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
+				first_non_wb_addr = max_addr;
 			}
 
 			if (total_mem >= mem_limit)
 				continue;
-			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
-			if (total_mem > mem_limit) {
-				md->num_pages -= ((total_mem - mem_limit) >> EFI_PAGE_SHIFT);
-				max_addr = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
+
+			if (total_mem + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
+				unsigned long limit_addr = md->phys_addr;
+
+				limit_addr += mem_limit - total_mem;
+				limit_addr &= ~(IA64_GRANULE_SIZE - 1);
+
+				if (md->phys_addr > limit_addr)
+					continue;
+
+				md->num_pages = (limit_addr - md->phys_addr) >>
+				                EFI_PAGE_SHIFT;
+				first_non_wb_addr = max_addr = md->phys_addr +
+				              (md->num_pages << EFI_PAGE_SHIFT);
 			}
+			total_mem += (md->num_pages << EFI_PAGE_SHIFT);
 
 			if (md->num_pages = 0)
 				continue;
@@ -495,13 +507,14 @@
 	for (cp = saved_command_line; *cp; ) {
 		if (memcmp(cp, "mem=", 4) = 0) {
 			cp += 4;
-			mem_limit = memparse(cp, &end) - 2;
+			mem_limit = memparse(cp, &end);
 			if (end != cp)
 				break;
 			cp = end;
 		} else if (memcmp(cp, "max_addr=", 9) = 0) {
 			cp += 9;
-			max_addr = memparse(cp, &end) - 1;
+			max_addr = (memparse(cp, &end) &
+			            ~(IA64_GRANULE_SIZE - 1));
 			if (end != cp)
 				break;
 			cp = end;


