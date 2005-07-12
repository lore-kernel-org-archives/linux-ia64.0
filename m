From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 12 Jul 2005 07:18:28 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <42D36EC4.6070204@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>This patch allows users to read region 5 from /dev/kmem and 
>>enhances range check of it.
> 
> 
> I'm uneasy about this change to drivers/char/mem.c.  Won't it stop
> those architectures that have memory at physical 0x0 from accessing
> it?
> 
>  		ptr = xlate_dev_mem_ptr(p);
> -
> +		if (!ptr)
> +			return -EFAULT
> 
I confirmed this is not necessary. I send fixed one.

Note:
linux-2.6.13-rc1  panic when "cat /dev/kmem > /dev/null".
I'ts because xlate_dev_kmem_ptr() doesn't uses pfn_valid() to access page struct.

Thanks,
Kamezawa Hiroyuki.
=

This patch allows to read region 5 of the kernel from /dev/kmem.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.13-rc1/include/asm-ia64/uaccess.h
=================================--- linux-2.6.13-rc1.orig/include/asm-ia64/uaccess.h	2005-07-12 14:40:37.000000000 +0900
+++ linux-2.6.13-rc1/include/asm-ia64/uaccess.h	2005-07-12 15:47:56.000000000 +0900
@@ -395,8 +395,27 @@
  {
  	struct page *page;
  	char * ptr;
+	unsigned long pfn;
+	int region;
+
+	region = REGION_NUMBER(p);
+
+	switch (region) {
+		case 6:
+			pfn = ((unsigned long)p - __IA64_UNCACHED_OFFSET) >> PAGE_SHIFT;
+			break;
+		case 7:
+			pfn = __pa(p) >> PAGE_SHIFT;
+			break;
+		default:
+			return p;
+	}
+	if (!pfn_valid(pfn))
+		return NULL; /* cause access error in copy_user */
+	if (region = 6)
+		return p;
+	page = pfn_to_page(pfn);

-	page = virt_to_page((unsigned long)p >> PAGE_SHIFT);
  	if (PageUncached(page))
  		ptr = (char *)__pa(p) + __IA64_UNCACHED_OFFSET;
  	else

