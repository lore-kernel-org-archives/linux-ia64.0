From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 May 2004 19:16:45 +0000
Subject: drop left-over #ifndef __ia64__
Message-Id: <200405201916.i4KJGjL5006355@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It used to be that loops_per_jiffy was a macro on ia64, hence it
couldn't be exported.  That's no longer the case though, so there is
no point in inhibiting its export (not that it makes any _sense_ to
export that value on ia64).

	--david

=== init/main.c 1.132 vs edited ==--- 1.132/init/main.c	Sat May  8 12:27:45 2004
+++ edited/init/main.c	Wed May 19 23:00:48 2004
@@ -169,9 +169,7 @@
    still work even if initially too large, it will just take slightly longer */
 unsigned long loops_per_jiffy = (1<<12);
 
-#ifndef __ia64__
 EXPORT_SYMBOL(loops_per_jiffy);
-#endif
 
 /* This is the number of bits of precision for the loops_per_jiffy.  Each
    bit takes on average 1.5/HZ seconds.  This (like the original) is a little
