From: Jack Steiner <steiner@sgi.com>
Date: Tue, 09 Dec 2008 16:51:32 +0000
Subject: [PATCH] - Fix GRU compile error w/o CONFIG_HUGETLB_PAGE
Message-Id: <20081209165132.GA26860@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: a.beregalov@gmail.com, kernel-testers@vger.kernel.org

Eliminate compile error when compiling without CONFIG_HUGETLB_PAGE.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 drivers/misc/sgi-gru/grufault.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/drivers/misc/sgi-gru/grufault.c
=================================--- linux.orig/drivers/misc/sgi-gru/grufault.c	2008-12-08 08:25:57.000000000 -0600
+++ linux/drivers/misc/sgi-gru/grufault.c	2008-12-09 09:35:02.000000000 -0600
@@ -254,7 +254,11 @@ static int atomic_pte_lookup(struct vm_a
 		return 1;
 
 	*paddr = pte_pfn(pte) << PAGE_SHIFT;
+#ifdef CONFIG_HUGETLB_PAGE
 	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
+#else
+	*pageshift = PAGE_SHIFT;
+#endif
 	return 0;
 
 err:
