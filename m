From: Greg Edwards <edwardsg@sgi.com>
Date: Wed, 11 Aug 2004 20:33:53 +0000
Subject: [PATCH] check page allocations in ia32 support code
Message-Id: <20040811203352.GA7683@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's pretty unlikely these page allocations would fail, but we should
still check them.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>

Greg


 ia32_support.c |    6 ++++++
 1 files changed, 6 insertions(+)

Index: work-26x-bk/arch/ia64/ia32/ia32_support.c
=================================--- work-26x-bk.orig/arch/ia64/ia32/ia32_support.c	2004-07-29 14:38:04.000000000 -0500
+++ work-26x-bk/arch/ia64/ia32/ia32_support.c	2004-08-11 15:17:55.000000000 -0500
@@ -145,6 +145,9 @@ ia32_gdt_init (void)
 	int cpu = smp_processor_id();
 
 	ia32_shared_page[cpu] = alloc_page(GFP_KERNEL);
+	if (!ia32_shared_page[cpu])
+		panic("failed to allocate ia32_shared_page[%d]\n", cpu);
+
 	cpu_gdt_table[cpu] = page_address(ia32_shared_page[cpu]);
 
 	/* Copy from the boot cpu's GDT */
@@ -161,6 +164,9 @@ ia32_boot_gdt_init (void)
 	unsigned long ldt_size;
 
 	ia32_shared_page[0] = alloc_page(GFP_KERNEL);
+	if (!ia32_shared_page[0])
+		panic("failed to allocate ia32_shared_page[0]\n");
+
 	ia32_boot_gdt = page_address(ia32_shared_page[0]);
 	cpu_gdt_table[0] = ia32_boot_gdt;
 
