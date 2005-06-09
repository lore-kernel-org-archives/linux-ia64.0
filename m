From: Russ Anderson <rja@sgi.com>
Date: Thu, 09 Jun 2005 22:40:36 +0000
Subject: [patch] Add page flag to indicate bad physical memory
Message-Id: <200506092240.j59MeauP6552266@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add a page flag to indicate that the page has bad physical 
memory (ECC error).  The MCA recovery code would set the
flag as part of discarding a bad page.  

This was previously discussed in the thread
"[patch] Remove limit on MCA recoveries".
http://www.gelato.unsw.edu.au/linux-ia64/0501/12605.html

Signed-off-by: Russ Anderson

-----------------------------------------------------------------------
Index: 2.6.12-git4/include/linux/page-flags.h
=================================--- 2.6.12-git4.orig/include/linux/page-flags.h	2005-06-09 13:37:44.709508040 -0500
+++ 2.6.12-git4/include/linux/page-flags.h	2005-06-09 17:15:14.256938046 -0500
@@ -75,7 +75,9 @@
 #define PG_mappedtodisk		17	/* Has blocks allocated on-disk */
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_nosave_free		19	/* Free, should not be written */
+
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_hard_error		21	/* Bad memory (ECC error) */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -306,6 +308,10 @@
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageHardError(page)	test_bit(PG_hard_error, &(page)->flags)
+#define SetPageHardError(page)	set_bit(PG_hard_error, &(page)->flags)
+#define ClearPageHardError(page) clear_bit(PG_hard_error, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
