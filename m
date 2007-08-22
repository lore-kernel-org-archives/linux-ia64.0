From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 22 Aug 2007 18:34:38 +0000
Subject: [PATCH]: Stop bogus NMI & softlockup warnings in ia64 show_mem
Message-Id: <20070822183438.14343.10614.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When dumping memory via sysrq-m it is possible to take a bogus NMI watchdog
or softlockup watchdog because the dump can take a long time on big memory
systems.

Occasionally tickle the watchdog when doing the dump.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 7ac8592..d3c538b 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -17,6 +17,7 @@
 #include <linux/bootmem.h>
 #include <linux/efi.h>
 #include <linux/mm.h>
+#include <linux/nmi.h>
 #include <linux/swap.h>
 
 #include <asm/meminit.h>
@@ -56,6 +57,8 @@ void show_mem(void)
 		present = pgdat->node_present_pages;
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
 			struct page *page;
+			if (unlikely(i % MAX_ORDER_NR_PAGES = 0))
+				touch_nmi_watchdog();
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
 			else {
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 0dbf0e8..0d34585 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -16,6 +16,7 @@
 
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/nmi.h>
 #include <linux/swap.h>
 #include <linux/bootmem.h>
 #include <linux/acpi.h>
@@ -533,6 +534,8 @@ void show_mem(void)
 		present = pgdat->node_present_pages;
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
 			struct page *page;
+			if (unlikely(i % MAX_ORDER_NR_PAGES = 0))
+				touch_nmi_watchdog();
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
 			else {
