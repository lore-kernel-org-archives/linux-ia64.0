From: Keith Owens <kaos@sgi.com>
Date: Thu, 01 Mar 2007 05:19:00 +0000
Subject: [patch 2.6.20] Remove sparse warning from unwind code
Message-Id: <23108.1172726340@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Running ia64 through sparse gives warnings in the unwind code.

  include/asm-ia64/unwind.h:84:17: error: dubious bitfield without explicit `signed' or `unsigned'

Make the bitfield explicitly unsigned.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/include/asm-ia64/unwind.h
=================================--- linux.orig/include/asm-ia64/unwind.h	2007-02-05 05:44:54.000000000 +1100
+++ linux/include/asm-ia64/unwind.h	2007-03-01 15:48:47.936874767 +1100
@@ -81,7 +81,7 @@ struct unw_frame_info {
 	struct unw_ireg {
 		unsigned long *loc;
 		struct unw_ireg_nat {
-			long type : 3;			/* enum unw_nat_type */
+			unsigned long type : 3;		/* enum unw_nat_type */
 			signed long off : 61;		/* NaT word is at loc+nat.off */
 		} nat;
 	} r4, r5, r6, r7;

