From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 01 Jul 2005 08:41:49 +0000
Subject: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010906060904060201010600"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010906060904060201010600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch allows users to read region 5 from /dev/kmem and enhances range check of it.

Regards,
-- Kamezawa Hiroyuki.

--------------010906060904060201010600
Content-Type: text/plain;
 name="ia64_region5_kmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64_region5_kmem.patch"


enables reading region 5 from /dev/kmem

This patch enables to read region 5 from /dev/kmem.
And 'cat /dev/kmem' never cause panic.
"Don't do that" is good advise :).

Signed-Off-By: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 linux-2.6.13-rc1-kamezawa/drivers/char/mem.c         |    3 +-
 linux-2.6.13-rc1-kamezawa/include/asm-ia64/uaccess.h |   22 +++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

diff -puN include/asm-ia64/uaccess.h~ia64_region5_kmem include/asm-ia64/uaccess.h
--- linux-2.6.13-rc1/include/asm-ia64/uaccess.h~ia64_region5_kmem	2005-07-01 17:10:05.000000000 +0900
+++ linux-2.6.13-rc1-kamezawa/include/asm-ia64/uaccess.h	2005-07-01 17:12:51.000000000 +0900
@@ -395,8 +395,26 @@ xlate_dev_kmem_ptr (char * p)
 {
 	struct page *page;
 	char * ptr;
-
-	page = virt_to_page((unsigned long)p >> PAGE_SHIFT);
+	unsigned long pfn;
+	int region;
+	region = REGION_NUMBER(p);
+	switch(region) {
+		case 5:
+			return p;
+		case 6:
+			pfn = ((unsigned long)p - __IA64_UNCACHED_OFFSET) >> PAGE_SHIFT;
+			break;
+		case 7:
+			pfn = __pa(p) >> PAGE_SHIFT;
+			break;
+		default:
+			return NULL;
+	}
+	if (!pfn_valid(pfn))
+		return NULL;
+	if (region == 6)
+		return p;
+	page = pfn_to_page(pfn);
 	if (PageUncached(page))
 		ptr = (char *)__pa(p) + __IA64_UNCACHED_OFFSET;
 	else
diff -puN drivers/char/mem.c~ia64_region5_kmem drivers/char/mem.c
--- linux-2.6.13-rc1/drivers/char/mem.c~ia64_region5_kmem	2005-07-01 17:13:06.000000000 +0900
+++ linux-2.6.13-rc1-kamezawa/drivers/char/mem.c	2005-07-01 17:13:15.000000000 +0900
@@ -155,7 +155,8 @@ static ssize_t read_mem(struct file * fi
 		 * by the kernel or data corruption may occur
 		 */
 		ptr = xlate_dev_mem_ptr(p);
-
+		if (!ptr)
+			return -EFAULT;
 		if (copy_to_user(buf, ptr, sz))
 			return -EFAULT;
 		buf += sz;

_

--------------010906060904060201010600--

