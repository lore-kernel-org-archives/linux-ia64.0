From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jun 2005 05:18:39 +0000
Subject: RE: gate page oops
Message-Id: <17062.32687.12421.554474@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 6 Jun 2005 17:06:23 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> I (finally) looked into this again and my current thinking is
  David> that it may be better to go back to mapping the two pages
  David> consecutively.  The gate-related code has an implicit
  David> assumption that the gate-area is occupying a single region of
  David> memory (that _could_ be changed, though).  Re-enabling the
  David> HAVE_BUGG_SEGREL code unconditionally should do that, at the
  David> expense of increasing the size of the kernel's ELF image by
  David> 16KB.  I need to double-check, but I think there won't be any
  David> other negative side-effects.

Well, it's easier to just map the holes with zero-pages.  The cost is
trivial (a few more non-zero kernel page-table entries) and it passes
all my testing (including coredumping and gdb single-stepping over an
EPC syscall).

Unless there are any objections, please apply (for 2.6.12, hopefully).

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
