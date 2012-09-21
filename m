From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 21 Sep 2012 04:30:25 +0000
Subject: [PATCH] ia64/xen: fix return value check in xencomm_vtop()
Message-Id: <CAPgLHd_Z-4j0KNuwy=i0PgoyB+Q3dHCmdey58cadeoqJbnbc4w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function follow_page() returns ERR_PTR()
or NULL pointer. The NULL test in the error handling should be
replaced with IS_ERR_OR_NULL().

dpatch engine is used to auto generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 arch/ia64/xen/xencomm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/xen/xencomm.c b/arch/ia64/xen/xencomm.c
index 1f5d7ac..cf4752f 100644
--- a/arch/ia64/xen/xencomm.c
+++ b/arch/ia64/xen/xencomm.c
@@ -98,7 +98,7 @@ xencomm_vtop(unsigned long vaddr)
 
 	/* We assume the page is modified.  */
 	page = follow_page(vma, vaddr, FOLL_WRITE | FOLL_TOUCH);
-	if (!page)
+	if (IS_ERR_OR_NULL(page))
 		return ~0UL;
 
 	return (page_to_pfn(page) << PAGE_SHIFT) | (vaddr & ~PAGE_MASK);


