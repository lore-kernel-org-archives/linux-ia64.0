From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Feb 2005 19:08:41 +0000
Subject: use fc.i for fluch_icache_range()
Message-Id: <200502181908.j1IJ8fTu021592@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a small patch to switch fluch_icache_range() to use fc.i
instead of fc.  This would save time on processors which can establish
i-cache coherency without flushing the cache-line out to memory (not
that any current processors do).  On existing processors, fc.i behaves
like fc.  The only caveat is that very old assemblers may not know
about fc.i yet.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/lib/flush.S 1.2 vs edited ==--- 1.2/arch/ia64/lib/flush.S	2002-02-04 23:39:13 -08:00
+++ edited/arch/ia64/lib/flush.S	2005-02-18 10:59:24 -08:00
@@ -1,8 +1,8 @@
 /*
  * Cache flushing routines.
  *
- * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001, 2005 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <asm/asmmacro.h>
 #include <asm/page.h>
@@ -26,7 +26,7 @@
 
 	mov ar.lc=r8
 	;;
-.Loop:	fc in0				// issuable on M0 only
+.Loop:	fc.i in0			// issuable on M2 only
 	add in02,in0
 	br.cloop.sptk.few .Loop
 	;;
