From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 01 Sep 2004 06:14:43 +0000
Subject: [1/1] make bad_page() print all of page->flags
Message-Id: <20040901061443.GW5492@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 01, 2004 at 03:59:33PM +1000, Ian Wienand wrote:
> With 2.6.9-rc1 on IA64 I have this problem when I boot on an rx2600
> (with both SMP and uniprocessor builds) :
> Bad page state at free_hot_cold_page (in process 'swapper', page e0000000049bcd08)
> flags:0x00000000 mapping:0000000000000000 mapcount:1 count:0
> Backtrace:
> [-- no backtrace is printed, unfortunately, and the machine stops dead --]
> But I also noticed that virtual mem map was right at around the same
> place :
> Virtual mem_map starts at 0xe000000004928000
> So I turned that off in the config, and it appears to work OK.  I
> noticed there were a lot of rmap changes with respect to locking just
> recently put in, and I suspect they are the culprit.  I'm afraid this
> is a little over my head, but I'm willing to try any suggestions.

(1) is this struct page actually in your virtual mem_map?
(2) page->flags looks 32-bit, but ia64 doesn't define
	ARCH_HAS_ATOMIC_UNSIGNED that I can tell; what's going on there?
	Let's see if those flags are really all zero.
(3) "stops dead" isn't a very good description; deadlock? livelock?
	interrupts on or off?


-- wli

bad_page() only prints out 8 hexadecimal digits of page->flags regardless
of sizeof(page_flags_t). This leads to confusing and/or incomplete bug
reports. The following patch uses a field width argument to replace the
hardcoded %08lx so that bad_page() may print the whole of page->flags.


Index: mm2-2.6.9-rc1/mm/page_alloc.c
=================================--- mm2-2.6.9-rc1.orig/mm/page_alloc.c	2004-08-31 01:06:55.000000000 -0700
+++ mm2-2.6.9-rc1/mm/page_alloc.c	2004-08-31 23:06:23.558598368 -0700
@@ -79,9 +79,9 @@
 {
 	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
 		function, current->comm, page);
-	printk(KERN_EMERG "flags:0x%08lx mapping:%p mapcount:%d count:%d\n",
-		(unsigned long)page->flags, page->mapping,
-		page_mapcount(page), page_count(page));
+	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
+		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
+		page->mapping, page_mapcount(page), page_count(page));
 	printk(KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n");
