From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 04 Nov 2005 19:57:00 +0000
Subject: [patch] MCA recovery: pfn_valid() needs a pfn
Message-Id: <200511041957.jA4Jv0xN049183@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] MCA recovery: pfn_valid() needs a pfn

paddr needs to be shifted by PAGE_SHIFT to be valid
input for pfn_valid().

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2005-11-04 11:10:08.869613186 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2005-11-04 11:10:59.376035037 -0600
@@ -88,7 +88,7 @@ mca_page_isolate(unsigned long paddr)
 	if (!ia64_phys_addr_valid(paddr))
 		return ISOLATE_NONE;
 
-	if (!pfn_valid(paddr))
+	if (!pfn_valid(paddr >> PAGE_SHIFT))
 		return ISOLATE_NONE;
 
 	/* convert physical address to physical page number */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
