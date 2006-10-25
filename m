From: Jes Sorensen <jes@sgi.com>
Date: Wed, 25 Oct 2006 09:49:53 +0000
Subject: [patch] don't double >> PAGE_SHIFT pointer for /dev/kmem access
Message-Id: <yq0ods07mim.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This one has been around for a while, but it's a pretty serious bug,
so if you would push it upstream quickly that would be great. Thanks
to Bjorn for spotting it.

Cheers,
Jes


Don't PAGE_SHIFT pointer before handing it to virt_to_page() in
xlate_dev_kmem_ptr() as it results in a double shift.

Spotted by Bjorn 'Eagleeye' Helgaas.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 include/asm-ia64/uaccess.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/include/asm-ia64/uaccess.h
=================================--- linux-2.6.orig/include/asm-ia64/uaccess.h
+++ linux-2.6/include/asm-ia64/uaccess.h
@@ -389,7 +389,7 @@ xlate_dev_kmem_ptr (char * p)
 	struct page *page;
 	char * ptr;
 
-	page = virt_to_page((unsigned long)p >> PAGE_SHIFT);
+	page = virt_to_page((unsigned long)p);
 	if (PageUncached(page))
 		ptr = (char *)__pa(p) + __IA64_UNCACHED_OFFSET;
 	else
