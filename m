From: Keith Owens <kaos@sgi.com>
Date: Fri, 18 Mar 2005 07:04:37 +0000
Subject: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <12404.1111129477@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

memcpy_mck.S::__copy_user breaks in the prefetch code under these
conditions :-

* src is unaligned and
* dst is near the end of a page and
* the page after dst is unmapped.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/lib/memcpy_mck.S
=================================--- linux.orig/arch/ia64/lib/memcpy_mck.S	2005-03-02 18:38:38.000000000 +1100
+++ linux/arch/ia64/lib/memcpy_mck.S	2005-03-18 17:49:44.000000000 +1100
@@ -300,7 +300,7 @@ .unaligned_src
 	add	src_pre_mem=0,src0	// prefetch src pointer
 	add	dst_pre_mem=0,dst0	// prefetch dest pointer
 	and	src0=-8,src0		// 1st src pointer
-(p7)	mov	ar.lc = r21
+(p7)	mov	ar.lc = cnt
 (p8)	mov	ar.lc = r0
 	;;
 	TEXT_ALIGN(32)


Test module follows.  vmalloc two pages, they should be contiguous.
Free the second page.  Using the first page, copy from an unaligned src
to the end of the page - 0x100, for a length of 0x100.  __copy_user
breaks at lfetch.fault.excl [dst_pre_mem], 128 in .unaligned_src.

The loop count in r21 is 1 value too high.  A length of 0x100 gives
ar.lc = r21 = 2.  .unaligned_src incorrectly copies r21 into ar.lc,
when it should copy cnt, so the lfetch lines are executed 3 times, not
2.  That takes dst_pre_mem past the end of the page and into an
unallocated area, oops.

#include <linux/config.h>
#include <linux/vmalloc.h>
#include <linux/module.h>
#include <asm/uaccess.h>

MODULE_LICENSE("GPL");

static int __init init_memcpy_test(void)
{
	char *p, *p1;
	printk("%s: start\n", __FUNCTION__);
	p = vmalloc(PAGE_SIZE);
	p1 = vmalloc(PAGE_SIZE);
	printk("%s: p %p p1 %p\n", __FUNCTION__, p, p1);
	vfree(p1);
	__copy_user(p+PAGE_SIZE-0x100, p+0x854, 0x100);
	vfree(p);
	printk("%s: end\n", __FUNCTION__);
	return 0;
}

static void __exit exit_memcpy_test(void) {}

module_init(init_memcpy_test)
module_exit(exit_memcpy_test)

