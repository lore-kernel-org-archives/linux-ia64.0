From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 04 Nov 2005 22:58:28 +0000
Subject: [patch] MCA recovery: Bump reference count on bad pages
Message-Id: <200511042258.jA4MwSJu051330@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] MCA recovery: Bump reference count on bad pages.

When a page has a memory uncorrectable ECC error, the recovery
code wants to prevent the page from being reused.  This change
bumps the reference count to prevent the page from getting back
on the free list.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c |    1 +
 1 files changed, 1 insertion(+)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2005-11-04 11:10:59.376035037 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2005-11-04 11:11:48.404099117 -0600
@@ -108,6 +108,7 @@ mca_page_isolate(unsigned long paddr)
 		return ISOLATE_NG;
 
 	/* add attribute 'Reserved' and register the page */
+	get_page(p);
 	SetPageReserved(p);
 	page_isolate[num_page_isolate++] = p;
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
