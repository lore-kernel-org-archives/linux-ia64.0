From: Andi Kleen <ak@suse.de>
Date: Thu, 24 Jun 2004 19:27:54 +0000
Subject: Increasing swiotlb default
Message-Id: <20040624212754.7dd1d68e.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hallo,

I discovered that swiotlb defaults to using only 2MB of RAM by default. That's IMHO
far too small, especially since the consequences of overflow are so severe
(panic) x86-64 has the same problem because it shares this code.

This patch increases it to 64MB by default.

-Andi

diff -u linux/arch/ia64/lib/swiotlb.c-o linux/arch/ia64/lib/swiotlb.c
--- linux/arch/ia64/lib/swiotlb.c-o	2004-04-06 13:12:00.000000000 +0200
+++ linux/arch/ia64/lib/swiotlb.c	2004-06-24 21:04:08.000000000 +0200
@@ -44,7 +44,7 @@
 /*
  * log of the size of each IO TLB slab.  The number of slabs is command line controllable.
  */
-#define IO_TLB_SHIFT 11
+#define IO_TLB_SHIFT 16
 
 /*
  * Used to do a quick range check in swiotlb_unmap_single and swiotlb_sync_single_*, to see
