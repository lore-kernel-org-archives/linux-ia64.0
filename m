From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 16 Sep 2005 21:54:53 +0000
Subject: [patch] MCA recovery verify pfn_valid
Message-Id: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Verify the pfn is valid before calling pfn_to_page().

Signed-off-by: Russ Anderson (rja@sgi.com)

---------------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.git#test/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.git#test.orig/arch/ia64/kernel/mca_drv.c	2005-09-16 16:28:11.857773257 -0500
+++ linux-2.6.git#test/arch/ia64/kernel/mca_drv.c	2005-09-16 16:29:32.119181669 -0500
@@ -87,6 +87,9 @@ mca_page_isolate(unsigned long paddr)
 	if ( !ia64_phys_addr_valid(paddr) ) 
 		return ISOLATE_NG;
 
+	if ( !pfn_valid(paddr))
+		return ISOLATE_OK;
+
 	/* convert physical address to physical page number */
 	p = pfn_to_page(paddr>>PAGE_SHIFT);
 
