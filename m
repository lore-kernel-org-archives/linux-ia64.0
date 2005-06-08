From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jun 2005 17:44:49 +0000
Subject: RE: gate page oops
Message-Id: <17063.11921.593856.534530@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Jun 2005 10:11:05 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Should we also map zero pages in the buggy linker case (since
  Tony> there is a hole from GATE_ADDR + 2*PAGE_SIZE to
  Tony> FIXADDR_USER_END where there are no mappings).  Or perhaps
  Tony> FIXADDR_USER_END should only be GATE_ADDR + 2*PAGE_SIZE in the
  Tony> buggy linker case?

Here is an updated patch.

	--david

[IA64] Fill holes in FIXADDR_USER space with zero pages.

This fixes an oops reported by Jason Baron.

 arch/ia64/mm/init.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -305,8 +305,9 @@ setup_gate (void)
 	struct page *page;
 
 	/*
-	 * Map the gate page twice: once read-only to export the ELF headers etc. and once
-	 * execute-only page to enable privilege-promotion via "epc":
+	 * Map the gate page twice: once read-only to export the ELF
+	 * headers etc. and once execute-only page to enable
+	 * privilege-promotion via "epc":
 	 */
 	page = virt_to_page(ia64_imva(__start_gate_section));
 	put_kernel_page(page, GATE_ADDR, PAGE_READONLY);
@@ -315,6 +316,20 @@ setup_gate (void)
 	put_kernel_page(page, GATE_ADDR + PAGE_SIZE, PAGE_GATE);
 #else
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
+	/* Fill in the holes (if any) with read-only zero pages: */
+	{
+		unsigned long addr;
+
+		for (addr = GATE_ADDR + PAGE_SIZE;
+		     addr < GATE_ADDR + PERCPU_PAGE_SIZE;
+		     addr += PAGE_SIZE)
+		{
+			put_kernel_page(ZERO_PAGE(0), addr,
+					PAGE_READONLY);
+			put_kernel_page(ZERO_PAGE(0), addr + PERCPU_PAGE_SIZE,
+					PAGE_READONLY);
+		}
+	}
 #endif
 	ia64_patch_gate();
 }


diff --git a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -8,7 +8,7 @@
  * This hopefully works with any (fixed) IA-64 page-size, as defined
  * in <asm/page.h>.
  *
- * Copyright (C) 1998-2004 Hewlett-Packard Co
+ * Copyright (C) 1998-2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
@@ -551,7 +551,11 @@ do {											\
 
 /* These tell get_user_pages() that the first gate page is accessible from user-level.  */
 #define FIXADDR_USER_START	GATE_ADDR
-#define FIXADDR_USER_END	(GATE_ADDR + 2*PERCPU_PAGE_SIZE)
+#ifdef HAVE_BUGGY_SEGREL
+# define FIXADDR_USER_END	(GATE_ADDR + 2*PAGE_SIZE)
+#else
+# define FIXADDR_USER_END	(GATE_ADDR + 2*PERCPU_PAGE_SIZE)
+#endif
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY


